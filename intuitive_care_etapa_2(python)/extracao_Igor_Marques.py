import tabula
import pandas as pd
import zipfile
import os

# Função para extrair dados do PDF
def extrair_dados_pdf(pdf_path):
    try:
        # Extrai as tabelas do PDF 
        tabelas = tabula.read_pdf(pdf_path, pages='all', multiple_tables=True, lattice=True)
        if not tabelas:
            print("Nenhuma tabela encontrada no PDF.")
            return None

        # uniao das tabelas em um dataframe
        df = pd.concat(tabelas, ignore_index=True)

        # Tirar espaço extra das colunas
        df.columns = df.columns.str.strip()

        # Ver quantas colunas tem
        print("Colunas extraídas:", df.columns)
        print("Número de colunas:", len(df.columns))
        
        #OBS: Tive alguns problemas, mas consegui fazer da maneira a seguir. Espero que esteja tudo bem =)
        # ajustar colunas(se o numero for superior a 14 na extracao)
        if len(df.columns) > 14:
            df = df.iloc[:, :14]  # Limita a 14 colunas

        # correcao de coluna
        if len(df.columns) == 14:
            # Verifique se a primeira coluna está vazia e mova as colunas para a esquerda, se necessário
            if df.iloc[:, 0].isnull().all():
                df = df.iloc[:, 1:].copy()  # Remove a primeira coluna vazia e desloca as demais
                df.columns = [
                    'PROCEDIMENTO', 'RN(alteração)', 'VIGÊNCIA', 'OD', 'AMB', 'HCO', 'HSO', 'REF',
                    'PAC', 'DUT', 'SUBGRUPO', 'GRUPO', 'CAPÍTULO'
                ]
        else:
            print(f"Atenção: O número de colunas não corresponde ao esperado ({len(df.columns)} != 14)")
        
        # Parte da tarefa abaixo, substituir as siglas pelo significado!
        if 'OD' in df.columns:
            df['OD'] = df['OD'].replace({'OD': 'Seg. Odontológica'})
        if 'AMB' in df.columns:
            df['AMB'] = df['AMB'].replace({'AMB': 'Seg. Ambulatorial'})


        return df

    except Exception as e:
        print(f"Ocorreu um erro ao extrair dados do PDF: {e}")
        return None

# Função para salvar os dados extraídos em um arquivo CSV
def salvar_csv(df, nome_arquivo):
    try:
        caminho_arquivo = os.path.join(os.path.dirname(os.path.abspath(__file__)), nome_arquivo)  # Caminho completo
        df.to_csv(caminho_arquivo, index=False, encoding='utf-8')
        print(f"Dados salvos em '{caminho_arquivo}'.")
    except Exception as e:
        print(f"Erro ao salvar o arquivo CSV: {e}")

# Função para compactar o CSV em um arquivo ZIP
def compactar_em_zip(arquivo_csv, nome_zip):
    try:
        caminho_csv = os.path.join(os.path.dirname(os.path.abspath(__file__)), arquivo_csv)  
        caminho_zip = os.path.join(os.path.dirname(os.path.abspath(__file__)), nome_zip)  
        with zipfile.ZipFile(caminho_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
            zipf.write(caminho_csv, os.path.basename(caminho_csv))
        print(f"Arquivo {arquivo_csv} compactado em '{caminho_zip}'.")
    except Exception as e:
        print(f"Erro ao compactar o arquivo: {e}")

# Caminho para o PDF
pdf_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Anexo_I_Rol_2021RN_465.2021_RN627L.2024.pdf')

# Extração de dados do PDF
df_tabela = extrair_dados_pdf(pdf_path)

if df_tabela is not None:
    # Salvando dados extraidos em CSV
    nome_csv = 'extracao_Dados.csv'  # Nome do arquivo CSV
    salvar_csv(df_tabela, nome_csv)

    # Compactando arquivo CSV em ZIP com o nome proposto
    nome_zip = 'Teste_IgorMarques.zip'  
    compactar_em_zip(nome_csv, nome_zip)
