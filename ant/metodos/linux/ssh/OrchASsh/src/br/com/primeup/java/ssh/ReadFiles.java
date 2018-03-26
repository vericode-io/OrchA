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

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class ReadFiles {
	String path;
	public ReadFiles(String path) {
		this.path = path;
	}
	public List<File> readFiles(){
		List<File> fileList = new ArrayList<File>();
		File file = new File(path);
		
		if(file.exists() && file.getName().endsWith(".txt")){
		
			fileList.add(file);
		}else{
			System.out.println("Arquivo de comandos não encontrado!");
			System.exit(0);
		}

		return fileList;
	}
	
	public List<String> listCommands(){
		List<String> lines = new ArrayList<String>();
		
		try {			
			for (File file : readFiles()) {
				Scanner scanner = new Scanner(file);
				while(scanner.hasNextLine()){
					lines.add(scanner.nextLine().trim());
				}
				scanner.close();
			}
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}		
		return lines;
	}
}
