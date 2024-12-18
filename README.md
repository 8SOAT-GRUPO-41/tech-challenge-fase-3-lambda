# 8SOAT FIAP Tech Challenge | Grupo 41 | Lambda Authorizer

Este projeto implementa um Lambda Authorizer utilizando AWS Lambda, API Gateway e Terraform para infraestrutura como código (IaC). O projeto também inclui um pipeline de deploy usando GitHub Actions.

## Infraestrutura como Código (IaC)

A infraestrutura é definida utilizando Terraform. Os principais componentes são:

- **API Gateway**: Configurado com rotas e integrações para gerenciar requisições HTTP.
- **Função Lambda**: Uma função Node.js que atua como um authorizer para o API Gateway.
- **IAM Role**: Fornece as permissões necessárias para a função Lambda.
- **VPC Link**: Conecta o API Gateway à VPC.

Os arquivos de configuração do Terraform são:

- `main.tf`: Define os data sources, recursos e suas configurações.
- `variables.tf`: Define as variáveis utilizadas na configuração do Terraform.
- `providers.tf`: Especifica os providers necessários e suas versões.
- `output.tf`: Exibe o ARN da função Lambda.

## Função Lambda

A função Lambda é implementada em Node.js e está localizada no arquivo `src/index.js`. Ela utiliza JSON Web Tokens (JWT) e JWKS (JSON Web Key Set) para verificar a autenticidade dos tokens. A função valida o token fornecido no cabeçalho `Authorization` e retorna um status de autorização.

### Handler

A função handler é definida como `src/index.handler` e realiza os seguintes passos:

1. Extrai o token do cabeçalho `Authorization`.
2. Verifica o token usando o endpoint JWKS.
3. Retorna o status de autorização com base na validade do token.

## Pipeline de Deploy

O pipeline de deploy é definido utilizando GitHub Actions e está localizado no arquivo `.github/workflows/deploy.yaml`. O pipeline realiza os seguintes passos:

1. **Checkout**: Faz o checkout do código do repositório.
2. **Configurar Node.js e Yarn**: Configura o ambiente Node.js e instala as dependências.
3. **Instalar e Empacotar Lambda**: Executa o script `package_lambda.sh` para instalar as dependências de produção e empacotar a função Lambda.
4. **Configurar Terraform**: Configura o Terraform e inicializa as configurações.
5. **Formatar Terraform**: Verifica o formato dos arquivos do Terraform.
6. **Inicializar Terraform**: Inicializa a configuração do Terraform.
7. **Validar Terraform**: Valida a configuração do Terraform.
8. **Planejar Terraform**: Cria um plano do Terraform para pull requests.
9. **Atualizar Pull Request**: Atualiza o pull request com a saída do plano do Terraform.
10. **Aplicar Terraform**: Aplica a configuração do Terraform no branch `main`.

## Executando Localmente

Para executar a função Lambda localmente, utilize os seguintes comandos:

```sh
# Iniciar o ambiente offline do serverless
npm run dev

# Invocar a função localmente com um evento de teste
npm run invoke:local
```
