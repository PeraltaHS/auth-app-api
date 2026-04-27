# Documento de Estrategia de Testes - App Auth

## 1. Objetivo

Este documento apresenta a estrategia de testes do App Auth, projeto voltado para autenticacao de usuarios.

O foco da estrategia esta nas tres principais funcionalidades do backend:

1. Cadastro de usuario
2. Login de usuario
3. Consulta de perfil autenticado

Cada funcionalidade possui suas regras de negocio e dois casos de teste.

## 2. Funcionalidade 1: Cadastro de usuario

Endpoint relacionado: `POST /register`

### Regras de negocio

- O usuario deve informar e-mail e senha para realizar o cadastro.
- O e-mail deve ser tratado antes de salvar, removendo espacos nas extremidades e convertendo para letras minusculas.
- Nao deve ser permitido cadastrar dois usuarios com o mesmo e-mail.
- A senha nao deve ser armazenada em texto puro.
- A senha deve ser protegida com salt e hash.
- Quando o cadastro for realizado com sucesso, a API deve retornar status `201`.
- Quando faltar e-mail ou senha, a API deve retornar status `400`.
- Quando o e-mail ja estiver cadastrado, a API deve retornar status `409`.

### Casos de teste

#### CT-01 - Cadastro com dados validos

- **Tipo:** Integracao
- **Cenario:** usuario informa e-mail e senha corretamente.
- **Passos:** enviar uma requisicao `POST /register` com e-mail e senha preenchidos.
- **Resultado esperado:** a API retorna status `201`, mensagem de usuario criado e `userId`.

#### CT-02 - Cadastro com e-mail duplicado

- **Tipo:** Integracao
- **Cenario:** usuario tenta cadastrar um e-mail que ja existe.
- **Passos:** cadastrar um usuario e depois enviar outro `POST /register` com o mesmo e-mail.
- **Resultado esperado:** a API retorna status `409` e a mensagem `email already registered`.

## 3. Funcionalidade 2: Login de usuario

Endpoint relacionado: `POST /login`

### Regras de negocio

- O usuario deve informar e-mail e senha para autenticar.
- O e-mail deve ser normalizado antes da busca.
- O login so deve ser autorizado quando o e-mail existir e a senha estiver correta.
- Credenciais invalidas nao devem informar se o erro esta no e-mail ou na senha.
- Quando o login for realizado com sucesso, a API deve retornar status `200`.
- Quando as credenciais forem invalidas, a API deve retornar status `401`.
- Em caso de sucesso, a API deve gerar um token JWT.
- O token JWT deve conter o identificador e o e-mail do usuario.

### Casos de teste

#### CT-03 - Login com credenciais validas

- **Tipo:** Integracao
- **Cenario:** usuario cadastrado informa e-mail e senha corretos.
- **Passos:** cadastrar um usuario e enviar `POST /login` com o mesmo e-mail e senha.
- **Resultado esperado:** a API retorna status `200` e um token JWT valido.

#### CT-04 - Validacao de senha incorreta

- **Tipo:** Unitario
- **Cenario:** senha informada nao corresponde ao hash armazenado.
- **Passos:** executar `PasswordHasher.verify` usando o salt e o hash de uma senha valida, mas informar uma senha diferente na verificacao.
- **Resultado esperado:** o metodo retorna `false`, impedindo a autenticacao do usuario.

## 4. Funcionalidade 3: Consulta de perfil autenticado

Endpoint relacionado: `GET /me`

### Regras de negocio

- O endpoint deve exigir o cabecalho `Authorization`.
- O cabecalho deve estar no formato `Bearer <token>`.
- O token informado deve ser validado antes de liberar o acesso.
- Quando o token for valido, a API deve retornar os dados do usuario autenticado.
- Quando o token estiver ausente, mal formatado ou invalido, a API deve negar o acesso.
- Em caso de sucesso, a API deve retornar status `200`.
- Em caso de falha de autenticacao, a API deve retornar status `403`.

### Casos de teste

#### CT-05 - Consulta de perfil com token valido

- **Tipo:** E2E
- **Cenario:** usuario cadastrado e autenticado consulta seus proprios dados.
- **Passos:** cadastrar usuario, realizar login, obter o token e enviar `GET /me` com `Authorization: Bearer <token>`.
- **Resultado esperado:** a API retorna status `200` com `userId` e `email` do usuario autenticado.

#### CT-06 - Consulta de perfil sem token

- **Tipo:** Integracao
- **Cenario:** usuario tenta acessar o perfil sem estar autenticado.
- **Passos:** enviar `GET /me` sem o cabecalho `Authorization`.
- **Resultado esperado:** a API retorna status `403`, informando que o cabecalho esta ausente ou invalido.

## 5. Resumo dos casos de teste

| Caso | Funcionalidade | Tipo |
| --- | --- | --- |
| CT-01 | Cadastro de usuario | Integracao |
| CT-02 | Cadastro de usuario | Integracao |
| CT-03 | Login de usuario | Integracao |
| CT-04 | Login de usuario | Unitario |
| CT-05 | Consulta de perfil autenticado | E2E |
| CT-06 | Consulta de perfil autenticado | Integracao |

## 6. Observacoes sobre classificacao

- **Teste unitario:** valida uma parte isolada do sistema, como uma funcao ou classe especifica.
- **Teste de integracao:** valida a comunicacao entre partes do sistema, como rota, controller e servico.
- **Teste E2E:** valida o fluxo completo do usuario, passando por mais de uma funcionalidade.

## 7. Criterios de aceite

- O documento apresenta as 3 principais funcionalidades do projeto.
- Cada funcionalidade possui suas regras de negocio.
- Cada funcionalidade possui pelo menos 2 casos de teste.
- O documento possui 6 casos de teste no total.
- Cada caso de teste esta classificado como Unitario, Integracao ou E2E.
