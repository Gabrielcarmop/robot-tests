*** Settings ***
Resource    ../resources/core_keywords.robot

Suite Setup       Log    Iniciando suíte de testes
Suite Teardown    Log    Finalizando suíte


*** Test Cases ***

# ======================================================
#                    TESTES DE LOGIN
# ======================================================

Testar Login com Erro 401
    Abrir Página de Login
    Fazer Login    tomsmith    senha_invalida
    Checar Erro 401
    Fechar Navegador

Testar Login com Sucesso
    Abrir Página de Login
    Fazer Login    tomsmith    SuperSecretPassword!
    Page Should Contain    ${MENSAGEM_SUCESSO}
    Capture Page Screenshot
    Fechar Navegador



# ======================================================
#                 TESTES DE OUTRAS PÁGINAS
# ======================================================

Testar Checkboxes
    Abrir Página de Login
    Go To    https://the-internet.herokuapp.com/checkboxes
    Click Element    xpath=//form/input[1]
    ${checked}=    Get Element Attribute    xpath=//form/input[1]    checked

    IF    "${checked}" != "true"
        Chamar Gemini e Criar Issue    Checkbox não marcou corretamente
    END

    Fechar Navegador



Testar Dropdown
    Abrir Página de Login
    Go To    https://the-internet.herokuapp.com/dropdown
    Select From List By Value    id=dropdown    2
    ${val}=    Get Selected List Value    id=dropdown

    IF    "${val}" != "2"
        Chamar Gemini e Criar Issue    Dropdown falhou ao selecionar opção 2
    END

    Fechar Navegador



Testar Dynamic Loading
    Abrir Página de Login
    Go To    https://the-internet.herokuapp.com/dynamic_loading/2
    Click Button    css=#start button
    Wait Until Element Is Visible    id=finish    timeout=10s

    ${txt}=    Get Text    id=finish

    IF    "${txt}" != "Hello World!"
        Chamar Gemini e Criar Issue    Dynamic Loading não exibiu o texto esperado
    END

    Fechar Navegador



Testar Upload
    Abrir Página de Login
    Go To    https://the-internet.herokuapp.com/upload
    Create File    ${CURDIR}/arquivo.txt    Teste upload
    Choose File    id=file-upload    ${CURDIR}/arquivo.txt
    Click Button    id=file-submit

    ${header}=    Get Text    css=h3

    IF    "File Uploaded!" not in "${header}"
        Chamar Gemini e Criar Issue    Upload não funcionou corretamente
    END

    Fechar Navegador



Testar Imagens Quebradas
    Abrir Página de Login
    Go To    https://the-internet.herokuapp.com/broken_images

    @{imgs}=    Get WebElements    css=img

    FOR    ${img}    IN    @{imgs}
        ${width}=    Call Method    ${img}    get_attribute    naturalWidth
        IF    "${width}" == "0"
            Chamar Gemini e Criar Issue    Imagem quebrada encontrada
        END
    END

    Fechar Navegador



Testar Typos
    Abrir Página de Login
    Go To    https://the-internet.herokuapp.com/typos

    ${texto}=    Get Text    css=.example p

    IF    "Sometimes you'll see a typo" not in "${texto}"
        Chamar Gemini e Criar Issue    Erro ortográfico detectado na página
    END

    Fechar Navegador
