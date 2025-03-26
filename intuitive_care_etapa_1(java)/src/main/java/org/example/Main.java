package org.example;

import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import java.io.File;
import java.io.IOException;

public class Main {
    public static void main(String[] args) {
        try {
            // diretório da pasta
            String downloadDir = "downloads";

            // Caso a pasta downloads não exista ainda
            File downloadsFolder = new File(downloadDir);
            if (!downloadsFolder.exists()) {
                boolean created = downloadsFolder.mkdir();
                if (created) {
                    System.out.println("Pasta de downloads criada com sucesso!");
                } else {
                    System.out.println("Falha ao criar a pasta de downloads.");
                }
            }

            // URL
            String url = "https://www.gov.br/ans/pt-br/acesso-a-informacao/participacao-da-sociedade/atualizacao-do-rol-de-procedimentos";

            // Pegando links
            String[] pdfLinks = WebScrapSite.getPdfLinks(url);

            // Parte do teste 1: Baixar os arquivos PDF =)
            for (String link : pdfLinks) {
                String fileName = downloadDir + File.separator + link.substring(link.lastIndexOf("/") + 1);

                // Baixar o arquivo
                BaixarArquivos.downloadFile(link, fileName);
                System.out.println("Arquivo baixado: " + fileName);
            }

            // Parte do teste 2: Compactacao dos arquivos na pasta em zip =)
            File[] filesToZip = downloadsFolder.listFiles((dir, name) -> name.endsWith(".pdf"));
            if (filesToZip != null && filesToZip.length > 0) {
                String zipFileName = downloadDir + File.separator + "arquivos_compactados.zip";
                ZipFile zipFile = new ZipFile(zipFileName);
                zipFile.addFiles(java.util.Arrays.asList(filesToZip));
                System.out.println("Arquivos compactados em: " + zipFileName);
            } else {
                System.out.println("Nenhum arquivo PDF encontrado para compactar.");
            }

        } catch (ZipException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
