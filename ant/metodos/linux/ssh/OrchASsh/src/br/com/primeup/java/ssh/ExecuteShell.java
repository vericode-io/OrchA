/*
   Copyright 2015 Prime Up Soluções em TI LTDA

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
package br.com.primeup.java.ssh;

import java.awt.BorderLayout;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Vector;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextField;

import ch.ethz.ssh2.Connection;
import ch.ethz.ssh2.InteractiveCallback;
import ch.ethz.ssh2.KnownHosts;
import ch.ethz.ssh2.ServerHostKeyVerifier;
import ch.ethz.ssh2.Session;

public class ExecuteShell
{

	static final String userHome = System.getProperty("user.home");
	static final String userName = System.getProperty("UA");
	static final String password = System.getProperty("PA");
	
	static final String knownHostPath = userHome + File.separator + ".ssh" + File.separator + "known_hosts";
	static final String idDSAPath = userHome + File.separator + ".ssh" + File.separator + "id_dsa";
	static final String idRSAPath = userHome + File.separator + ".ssh" + File.separator + "id_rsa";

	JFrame loginFrame = null;
	JLabel hostLabel;
	JLabel userLabel;
	JTextField hostField;
	JTextField userField;
	JButton loginButton;

	KnownHosts database = new KnownHosts();
	Vector<String> stringResponse = new Vector<String>();

	public ExecuteShell()
	{
		
//		for (Entry<Object, Object>p : System.getProperties().entrySet()) {
//			
//			System.out.println(p.getKey() + "=" + p.getValue());
//		}
		
		
		File knownHostFile = new File(knownHostPath);
		if (knownHostFile.exists())
		{
			try
			{
				database.addHostkeys(knownHostFile);
			}
			catch (IOException e)
			{
			}
		}
	}

	class EnterSomethingDialog extends JDialog
	{
		private static final long serialVersionUID = 1L;

		JTextField answerField;
		JPasswordField passwordField;

		final boolean isPassword;

		String answer;

		public EnterSomethingDialog(JFrame parent, String title, String content, boolean isPassword)
		{
			this(parent, title, new String[] { content }, isPassword);
		}

		public EnterSomethingDialog(JFrame parent, String title, String[] content, boolean isPassword)
		{
			super(parent, title, true);

			this.isPassword = isPassword;

			JPanel pan = new JPanel();
			pan.setLayout(new BoxLayout(pan, BoxLayout.Y_AXIS));

			for (int i = 0; i < content.length; i++)
			{
				if ((content[i] == null) || (content[i] == ""))
					continue;
				JLabel contentLabel = new JLabel(content[i]);
				pan.add(contentLabel);

			}

			answerField = new JTextField(20);
			passwordField = new JPasswordField(20);

			if (isPassword)
				pan.add(passwordField);
			else
				pan.add(answerField);

			KeyAdapter kl = new KeyAdapter()
			{
				public void keyTyped(KeyEvent e)
				{
					if (e.getKeyChar() == '\n')
						finish();
				}
			};

			answerField.addKeyListener(kl);
			passwordField.addKeyListener(kl);

			getContentPane().add(BorderLayout.CENTER, pan);

			setResizable(false);
			pack();
			setLocationRelativeTo(null);
		}

		private void finish()
		{
			if (isPassword)
				answer = new String(passwordField.getPassword());
			else
				answer = answerField.getText();

			dispose();
		}
	}

	class ExecuteCommand 
	{

		Session sess;
		InputStream in;
		OutputStream out;
		
		int commandPosition=0;
		List<String> commandList=null;
		

		int x, y;

		class RemoteConsumer extends Thread
		{
			
			char[][] lines = new char[y][];
			int posy = 0;
			int posx = 0;
	
			
			public RemoteConsumer() {
				
			}
			
			private void addText(byte[] data, int len) throws IOException
			{
				for (int i = 0; i < len; i++)
				{
					char c = (char) (data[i] & 0xff);

					if (c == 8) // Backspace, VERASE
					{
						if (posx < 0)
							continue;
						posx--;
						continue;
					}

					if (c == '\r')
					{
						posx = 0;
						continue;
					}

					if (c == '\n')
					{
						posy++;
						if (posy >= y)
						{
							for (int k = 1; k < y; k++)
								lines[k - 1] = lines[k];
							posy--;
							lines[y - 1] = new char[x];
							for (int k = 0; k < x; k++)
								lines[y - 1][k] = ' ';
						}
						continue;
					}

					if (c < 32)
					{
						continue;
					}

					if (posx >= x)
					{
						posx = 0;
						posy++;
						if (posy >= y)
						{
							posy--;
							for (int k = 1; k < y; k++)
								lines[k - 1] = lines[k];
							lines[y - 1] = new char[x];
							for (int k = 0; k < x; k++)
								lines[y - 1][k] = ' ';
						}
					}

					if (lines[posy] == null)
					{
						lines[posy] = new char[x];
						for (int k = 0; k < x; k++)
							lines[posy][k] = ' ';
					}

					lines[posy][posx] = c;
					posx++;
				}

				StringBuffer sb = new StringBuffer(x * y);

				for (int i = 0; i < lines.length; i++)
				{
					if (i != 0)
						sb.append('\n');

					if (lines[i] != null)
					{
						sb.append(lines[i]);
					}

				}

				stringResponse.add(sb.toString());
			
			}

			public void run()
			{
				byte[] buff = new byte[8192];

				try
				{
					while (true)
					{
						int len = in.read(buff);
						if (len == -1)
							return;
						addText(buff, len);
					}
				}
				catch (Exception e)
				{
				}
			}

			public void start(OutputStream out) {
				// TODO Auto-generated method stub
				
			}
		}

		public ExecuteCommand(Session sess,String pwd, List<String> commandList, String pathOutput) throws Exception
		{
			
			in = sess.getStdout();
			out = sess.getStdin();
			this.x = 90;
			this.y = 30;
			this.commandList = commandList;


			new RemoteConsumer().start();

			while(true){
				Thread.sleep(2000);
				String s = stringResponse.lastElement();
				if(s== null){
					s = "NNNNNNNNNNNNNNNN";
				}
				try {
					
					
					if(commandPosition == commandList.size()){
						SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_hhmmss");
						WriteLog log = new WriteLog(pathOutput+ "/" + sdf.format(new Date()) + "_shell_output.txt");
						log.log(s.trim());
						log.close();
						System.out.println("\n--------- output shell -----------");
						System.out.println(s.trim());
						System.exit(0);
						
					}

					s = s.trim();
					if(s.endsWith("$") || s.endsWith("#")){
						System.out.println("Executando:" + commandList.get(commandPosition));
						out.write((commandList.get(commandPosition) + "\n").getBytes());
						commandPosition++;
					}
					
					if(s.endsWith(":")){
						out.write(( pwd+ "\n").getBytes());
					}
					
				} catch (Exception e) {
					e.printStackTrace();
					
				}	
				
			}
		}
	}

	class AdvancedVerifier implements ServerHostKeyVerifier
	{
		public boolean verifyServerHostKey(String hostname, int port, String serverHostKeyAlgorithm,
				byte[] serverHostKey) throws Exception
		{
			final String host = hostname;
			final String algo = serverHostKeyAlgorithm;

			String message;

			/* Check database */

			int result = database.verifyHostkey(hostname, serverHostKeyAlgorithm, serverHostKey);

			switch (result)
			{
			case KnownHosts.HOSTKEY_IS_OK:
				return true;

			case KnownHosts.HOSTKEY_IS_NEW:
				message = "Do you want to accept the hostkey (type " + algo + ") from " + host + " ?\n";
				
				String hexFingerprint = KnownHosts.createHexFingerprint(serverHostKeyAlgorithm, serverHostKey);
				String bubblebabbleFingerprint = KnownHosts.createBubblebabbleFingerprint(serverHostKeyAlgorithm,
						serverHostKey);

				message += "Hex Fingerprint: " + hexFingerprint + "\nBubblebabble Fingerprint: " + bubblebabbleFingerprint;
				/* Be really paranoid. We use a hashed hostname entry */

				String hashedHostname = KnownHosts.createHashedHostname(hostname);

				/* Add the hostkey to the in-memory database */

				database.addHostkey(new String[] { hashedHostname }, serverHostKeyAlgorithm, serverHostKey);

				/* Also try to add the key to a known_host file */

				try
				{
					KnownHosts.addHostkeyToFile(new File(knownHostPath), new String[] { hashedHostname },
							serverHostKeyAlgorithm, serverHostKey);
				}
				catch (IOException ignore)
				{
				}

				return true;
				
			//	break;

			case KnownHosts.HOSTKEY_HAS_CHANGED:
				message = "WARNING! Hostkey for " + host + " has changed!\nAccept anyway?\n";
				break;

			default:
				throw new IllegalStateException();
			}

			/* Include the fingerprints in the message */

			String hexFingerprint = KnownHosts.createHexFingerprint(serverHostKeyAlgorithm, serverHostKey);
			String bubblebabbleFingerprint = KnownHosts.createBubblebabbleFingerprint(serverHostKeyAlgorithm,
					serverHostKey);

			message += "Hex Fingerprint: " + hexFingerprint + "\nBubblebabble Fingerprint: " + bubblebabbleFingerprint;

			/* Now ask the user */

			return false;
		}
	}

	/**
	 * The logic that one has to implement if "keyboard-interactive" autentication shall be
	 * supported.
	 *
	 */
	class InteractiveLogic implements InteractiveCallback
	{
		int promptCount = 0;
		String lastError;

		public InteractiveLogic(String lastError)
		{
			this.lastError = lastError;
		}

		/* the callback may be invoked several times, depending on how many questions-sets the server sends */

		public String[] replyToChallenge(String name, String instruction, int numPrompts, String[] prompt,
				boolean[] echo) throws IOException
		{
			String[] result = new String[numPrompts];

			for (int i = 0; i < numPrompts; i++)
			{
				/* Often, servers just send empty strings for "name" and "instruction" */

				String[] content = new String[] { lastError, name, instruction, prompt[i] };

				if (lastError != null)
				{
					/* show lastError only once */
					lastError = null;
				}

				EnterSomethingDialog esd = null;
				
//				esd = new EnterSomethingDialog(loginFrame, "Keyboard Interactive Authentication",
//						content, !echo[i]);
//
//				esd.setVisible(true);

				if (esd == null || esd.answer == null)
					throw new IOException("Keyboard Interactive Authentication Login. aborted.");

				result[i] = esd.answer;
				promptCount++;
			}

			return result;
		}

		/* We maintain a prompt counter - this enables the detection of situations where the ssh
		 * server is signaling "authentication failed" even though it did not send a single prompt.
		 */

		public int getPromptCount()
		{
			return promptCount;
		}
	}

	class ConnectionThread extends Thread
	{
		String hostname;
		String username;
		String pwd;
		String path;
		String pathOutput;
		
		public ConnectionThread(String hostname, String username, String pwd,String path, String pathOutput)
		{
			this.hostname = hostname;
			this.username = username;
			this.pwd = pwd;
			this.path = path;
			this.pathOutput = pathOutput;
			
		}

		public void run()
		{
			Connection conn = new Connection(hostname);

			try
			{
				/*
				 * 
				 * CONNECT AND VERIFY SERVER HOST KEY (with callback)
				 * 
				 */

				String[] hostkeyAlgos = database.getPreferredServerHostkeyAlgorithmOrder(hostname);

				if (hostkeyAlgos != null)
					conn.setServerHostKeyAlgorithms(hostkeyAlgos);

				conn.connect(new AdvancedVerifier());

				/*
				 * 
				 * AUTHENTICATION PHASE
				 * 
				 */

				boolean enableKeyboardInteractive = true;
				boolean enableDSA = true;
				boolean enableRSA = true;

				String lastError = null;

				while (true)
				{
					
					if (lastError != null ) {
						System.out.println("last error = " + lastError);
						lastError = null;
					}
					
					if ((enableDSA || enableRSA) && conn.isAuthMethodAvailable(username, "publickey"))
					{
						if (enableDSA)
						{
							File key = new File(idDSAPath);

							if (key.exists())
							{
								System.out.println("idDSAPath existe... tentando autenticar por ele... (username:" + username + ")");
//								EnterSomethingDialog esd = new EnterSomethingDialog(loginFrame, "DSA Authentication",
//										new String[] { lastError, "Enter DSA private key password:" }, true);
//								esd.setVisible(true);

//								boolean res = conn.authenticateWithPublicKey(username, key, esd.answer);
								boolean res = conn.authenticateWithPublicKey(username, key, null);

								if (res == true)
									break;

								lastError = "DSA authentication failed.";
							}
							enableDSA = false; // do not try again
						}

						if (enableRSA)
						{
							File key = new File(idRSAPath);

							if (key.exists())
							{
								
								System.out.println("idRSAPath existe... tentando autenticar por ele... (username:" + username + ")");
								
//								EnterSomethingDialog esd = new EnterSomethingDialog(loginFrame, "RSA Authentication",
//										new String[] { lastError, "Enter RSA private key password:" }, true);
//								esd.setVisible(true);

								//boolean res = conn.authenticateWithPublicKey(username, key, esd.answer);
								boolean res = conn.authenticateWithPublicKey(username, key, null);

								if (res == true)
									break;
								

								lastError = "RSA authentication failed.";
								
							}
							enableRSA = false; // do not try again
						}

						continue;
					}

					if (enableKeyboardInteractive && conn.isAuthMethodAvailable(username, "keyboard-interactive"))
					{
						InteractiveLogic il = new InteractiveLogic(lastError);

						boolean res = conn.authenticateWithKeyboardInteractive(username, il);

						if (res == true)
							break;

						if (il.getPromptCount() == 0)
						{
							// aha. the server announced that it supports "keyboard-interactive", but when
							// we asked for it, it just denied the request without sending us any prompt.
							// That happens with some server versions/configurations.
							// We just disable the "keyboard-interactive" method and notify the user.

							lastError = "Keyboard-interactive does not work.";

							enableKeyboardInteractive = false; // do not try this again
						}
						else
						{
							lastError = "Keyboard-interactive auth failed."; // try again, if possible
						}

						continue;
					}

					if (conn.isAuthMethodAvailable(username, "password"))
					{
						
						System.out.println("autenticando por user/pass");
						boolean res = conn.authenticateWithPassword(username, pwd);

						if (res == true)
							break;

						lastError = "Password authentication failed."; // try again, if possible

						continue;
					}

					throw new IOException("No supported authentication methods available.");
				}

				/*
				 * 
				 * AUTHENTICATION OK. DO SOMETHING.
				 * 
				 */

				Session sess = conn.openSession();

				int x_width = 90;
				int y_width = 30;

				sess.requestPTY("dumb", x_width, y_width, 0, 0, null);
				sess.startShell();
				
				ReadFiles readFiles = new ReadFiles(path);
				List<String> listCommands=readFiles.listCommands();

				ExecuteCommand td = new ExecuteCommand(sess, pwd, listCommands, pathOutput);

				/* The following call blocks until the dialog has been closed */

				//td.setVisible(true);

			}
			catch (Exception e)
			{
				e.printStackTrace();
				//JOptionPane.showMessageDialog(loginFrame, "Exception: " + e.getMessage());
			}

			/*
			 * 
			 * CLOSE THE CONNECTION.
			 * 
			 */

			conn.close();
		}
	}


	void start(String hostname, String user, String pwd, String path, String pathOutput)
	{

		ConnectionThread ct = new ConnectionThread(hostname,user,pwd, path, pathOutput);

		ct.start();
	}

	public static void main(String[] args)
	{
		ExecuteShell client = new ExecuteShell();
		
		if(args.length != 5 && args.length != 4){
			
			System.out.println("args needed: host,user,pwd,dir_commands");
			System.out.println(" or ");
			System.out.println("args needed: host,user,dir_commands");
			System.out.println();
			System.out.println("args passed:");
			
			StringBuilder sb = new StringBuilder();
			
			for (String s : args) {
				sb.append(" " + s);
			}
			System.out.println(sb);
			
			System.exit(0);
		}
		
		if (args.length == 5) {
			
			
					
			if (!"".equals(userName)) {
				System.out.println("Iniciando SSH......... user/pass (env)");
				client.start(args[0],userName,password, args[3], args[4]);
			} else {
				System.out.println("Iniciando SSH......... user/pass (csv)");
				client.start(args[0],args[1],password, args[3], args[4]);
			}
			
		} else if (args.length == 4) {
			System.out.println("Iniciando SSH......... user/chave");
			client.start(args[0],args[1],null, args[2], args[3]);
		}
	//	client.startGUI(null,null,null);
	}
}
