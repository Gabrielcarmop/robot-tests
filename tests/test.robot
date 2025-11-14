** Settings ***
Documentation Suite de testes executada via GitHub Actions com integração Gemini + GitHub
Resource ../resources/keywords.resource
Suite Setup Preparar Ambiente
Suite Teardown Finalizar Ambiente

*** Test Cases ***

Login
[Tags] login
Acessar Página de Login
Realizar Login Com Credenciais Válidas
Validar Login Bem Sucedido
Enviar Resultado Para Gemini E Criar Issue Se Necessário

Upload
[Tags] upload
Acessar Página de Upload
Realizar Upload De Arquivo
Validar Upload Bem Sucedido
Enviar Resultado Para Gemini E Criar Issue Se Necessário

Download
[Tags] download
Acessar Página de Download
Realizar Download De Arquivo
Validar Download
Enviar Resultado Para Gemini E Criar Issue Se Necessário

Dynamic Loading
[Tags] dynamic_loading
Acessar Dynamic Loading
Iniciar Dynamic Loading
Validar Dynamic Loading
Enviar Resultado Para Gemini E Criar Issue Se Necessário