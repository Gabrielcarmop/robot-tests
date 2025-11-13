*** Settings ***
Resource    keywords.resource
Suite Setup    Preparar Ambiente
Suite Teardown    Finalizar Ambiente


***Test Cases***
Login
    Executar Fluxo Padrao    Login

Upload
    Executar Fluxo Padrao    Upload

Download
    Executar Fluxo Padrao    Download

Dynamic Loading
    Executar Fluxo Padrao    Dynamic Loading
