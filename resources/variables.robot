*** Variables ***
${BASE_URL}=           https://the-internet.herokuapp.com
${GEMINI_URL}=         https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent

# Variáveis vindas do GitHub Actions como ENV
${GEMINI_API_KEY}=     %{GEMINI_API_KEY}
${MY_GITHUB_TOKEN}=    %{MY_GITHUB_TOKEN}
${GITHUB_REPO}=        %{GITHUB_REPO}

# Login
${LOGIN_USER}=         tomsmith
${LOGIN_PASSWORD}=     SuperSecretPassword!

# Upload
${UPLOAD_FILE}=        ${CURDIR}/../resources/teste.txt
