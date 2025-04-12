*** Settings ***
Library           SeleniumLibrary
Resource          ../resources/login_keywords.resource
Variables         ../variables/variables.py

Suite Setup       Abrir Página de Login
Suite Teardown    Fechar Navegador

*** Test Cases ***
Login Válido
    Inputar Usuário    ${VALID_USERNAME}
    Inputar Senha      ${VALID_PASSWORD}
    Enviar Formulário
    Page Should Contain    You logged into a secure area!

Login Inválido
    Inputar Usuário    usuario_invalido
    Inputar Senha      senha_errada
    Enviar Formulário
    Page Should Contain    Your username is invalid!
