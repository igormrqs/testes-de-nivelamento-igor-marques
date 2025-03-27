-- Criando o banco de dados
CREATE DATABASE IF NOT EXISTS ans_operadoras;
USE ans_operadoras;

-- Criando tabela para dados das operadoras
CREATE TABLE IF NOT EXISTS operadoras_ativas (
    registro_ans INT PRIMARY KEY,
    cnpj VARCHAR(18),
    razao_social VARCHAR(300),
    nome_fantasia VARCHAR(200),
    modalidade VARCHAR(100),
    logradouro VARCHAR(300),
    numero VARCHAR(20),
    complemento VARCHAR(300),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf CHAR(2),
    cep VARCHAR(10),
    ddd VARCHAR(3),
    telefone VARCHAR(20),
    fax VARCHAR(20),
    email VARCHAR(300),
    representante VARCHAR(300),
    cargo_representante VARCHAR(150)
);

-- Criando tabela para as despesas(financeiro em geral)
CREATE TABLE IF NOT EXISTS despesas_eventos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data DATE,
    registro_ans INT,
    codigo_conta_contabil VARCHAR(50),
    descricao VARCHAR(300),
    saldo_inicial DECIMAL(15,2),
    saldo_final DECIMAL(15,2),
    FOREIGN KEY (registro_ans) REFERENCES operadoras_ativas(registro_ans)
);

-- Importando CSV
LOAD DATA LOCAL INFILE 'D:/Downloads/Relatorio_cadop.csv'
INTO TABLE operadoras_ativas
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(registro_ans, cnpj, razao_social, nome_fantasia, modalidade, 
 logradouro, numero, complemento, bairro, cidade, uf, cep, 
 ddd, telefone, fax, email, representante, cargo_representante);

-- Importando os dados financeiros(repetir com todos os trimestres).
LOAD DATA LOCAL INFILE 'D:/Downloads/1T2023.csv'
INTO TABLE despesas_eventos
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@data, @registro_ans, @codigo_conta_contabil, @descricao, @saldo_inicial, @saldo_final)
SET 
    data = STR_TO_DATE(@data, '%Y-%m-%d'),
    registro_ans = NULLIF(@registro_ans, ''),
    codigo_conta_contabil = @codigo_conta_contabil,
    descricao = @descricao,
    saldo_inicial = REPLACE(REPLACE(@saldo_inicial, '.', ''), ',', '.'),
    saldo_final = REPLACE(REPLACE(@saldo_final, '.', ''), ',', '.');


-- 10 operadoras com maiores despesas no último trimestre
CREATE OR REPLACE VIEW top_10_despesas_trimestre AS
SELECT 
    o.registro_ans,
    o.razao_social,
    ROUND(SUM(d.saldo_final), 2) AS total_despesas
FROM despesas_eventos d
JOIN operadoras_ativas o ON d.registro_ans = o.registro_ans
WHERE d.descricao LIKE '%EVENTOS/SINISTROS CONHECIDOS OU AVISADOS DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR%'
  AND d.data >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY o.registro_ans, o.razao_social
ORDER BY total_despesas DESC
LIMIT 10;

-- 10 operadoras com maiores despesas no último ano
CREATE OR REPLACE VIEW top_10_despesas_ano AS
SELECT 
    o.registro_ans,
    o.razao_social,
    ROUND(SUM(d.saldo_final), 2) AS total_despesas
FROM despesas_eventos d
JOIN operadoras_ativas o ON d.registro_ans = o.registro_ans
WHERE d.descricao LIKE '%EVENTOS/SINISTROS CONHECIDOS OU AVISADOS DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR%'
  AND d.data >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY o.registro_ans, o.razao_social
ORDER BY total_despesas DESC
LIMIT 10;
