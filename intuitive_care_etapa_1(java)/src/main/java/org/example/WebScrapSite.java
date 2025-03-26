package org.example;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.jsoup.nodes.Element;

import java.io.IOException;

public class WebScrapSite {

    // Metodo principal
    public static void main(String[] args) {
        String url = "https://www.gov.br/ans/pt-br/acesso-a-informacao/participacao-da-sociedade/atualizacao-do-rol-de-procedimentos";

        try {
            // Chama o metodo para pegar os links
            String[] pdfLinks = getPdfLinks(url);

            // Mostra os links
            for (String link : pdfLinks) {
                System.out.println("Link encontrado: " + link);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Coleta os links
    public static String[] getPdfLinks(String url) throws IOException {
        Document doc = Jsoup.connect(url).get();
        Elements pdfLinks = doc.select("a[href$=.pdf]");

        // Retorna os links
        return pdfLinks.stream()
                .map(link -> link.attr("href"))
                .toArray(String[]::new);
    }
}