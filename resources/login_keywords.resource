*** Variables ***
${URL_LOGIN}    https://the-internet.herokuapp.com/login

*** Keywords ***
Abrir Página de Login
    Open Browser    ${URL_LOGIN}    chrome
    Maximize Browser Window

Inputar Usuário
    [Arguments]    ${usuario}
    Input Text    id=username    ${usuario}

Inputar Senha
    [Arguments]    ${senha}
    Input Text    id=password    ${senha}

Enviar Formulário
    Click Button    css=button.radius

Fechar Navegador
    Close Browser
