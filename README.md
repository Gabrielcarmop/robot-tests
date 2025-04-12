# 🤖 Robot Framework - Estudo de Caso em Automação de Testes Funcionais

Este projeto é um estudo de caso utilizando o **Robot Framework** para automatizar testes funcionais em uma aplicação web real de demonstração.

O objetivo é explorar a aplicação prática da ferramenta, abordando conceitos como reutilização de palavras-chave (keywords), organização de testes, separação de responsabilidades e geração de relatórios automáticos.

---

## 🌐 Site de Testes Utilizado

- [https://the-internet.herokuapp.com/login](https://the-internet.herokuapp.com/login)  
  Uma aplicação pública voltada para prática de automação de testes.

---

## 🛠 Tecnologias Utilizadas

- [Robot Framework](https://robotframework.org/)
- [SeleniumLibrary](https://robotframework.org/SeleniumLibrary/)
- Python 3.x

---

## 📁 Estrutura do Projeto

```
robot-tests/
├── tests/              # Casos de teste (suites)
│   └── login_test.robot
├── resources/          # Palavras-chave reutilizáveis
│   └── login_keywords.resource
├── variables/          # Variáveis globais em Python
│   └── variables.py
├── results/            # Relatórios e evidências geradas
└── README.md           # Documentação do projeto
```

---

## ▶️ Como Executar

### 1. Clonar o repositório

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```

### 2. Instalar dependências

```bash
pip install -r requirements.txt
```

### 3. Executar os testes

```bash
robot -d results tests/
```

Após a execução, os relatórios estarão disponíveis na pasta `results/`.

---

## 📈 Relatórios Gerados

- `report.html` → visão geral da execução
- `log.html` → detalhes passo a passo
- `output.xml` → resultado em formato XML

---

## 🎓 Sobre o Projeto

Este projeto foi desenvolvido como parte de um **estudo de caso para o Trabalho de Conclusão de Curso (TCC)**, com foco em demonstrar a eficácia da automação de testes funcionais utilizando Robot Framework.

---

## 📄 Licença

Este projeto está licenciado sob a licença MIT.  
Sinta-se à vontade para utilizar, modificar e compartilhar conforme necessário.

---
