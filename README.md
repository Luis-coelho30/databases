## Diagramas de Fluxo de Dados

### Nível 0
```mermaid
flowchart LR
    %% Entidades externas
    Customer[Cliente]
    Seller[Vendedor]
    PaymentGateway[Gateway de Pagamento]

    %% Processo principal
    System((Sistema E-commerce))

    %% Armazenamento
    DB[(Banco de Dados)]

    %% Fluxos Cliente
    Customer -->|Cadastro / Login / Compra| System
    System -->|Confirmação / Status do Pedido| Customer

    %% Fluxos Vendedor
    Seller -->|Cadastro de Produtos / Estoque| System
    System -->|Pedidos Recebidos / Relatórios| Seller

    %% Fluxos Pagamento
    System -->|Solicitação de Pagamento| PaymentGateway
    PaymentGateway -->|Status do Pagamento| System

    %% Banco de dados
    System -->|"Persistência (users, orders, products, payments)"| DB
    DB -->|Dados| System
```

### Nível 1
```mermaid
flowchart LR
    %% Entidades Externas
    Customer[Cliente]
    Seller[Vendedor]
    PaymentGateway[Gateway de Pagamento]

    subgraph System ["Sistema E-commerce (Backend)"]
        direction TB
        Auth[Módulo de Usuário]
        Catalog[Gestão de Catálogo]
        OrderMgmt[Processamento de Pedidos]
        Finance[Motor Financeiro]
    end

    DB[(Banco de Dados)]

    %% Fluxos do Cliente
    Customer -->|Login / Endereços| Auth
    Customer -->|Navegação / Compra| Catalog
    Catalog -->|Geração de Order| OrderMgmt
    OrderMgmt -->|Status / Histórico| Customer

    %% Fluxos do Vendedor
    Seller -->|Produtos / SKU / Estoque| Catalog
    Seller -->|"Consulta de Saldo (Balance) / Payout"| Finance
    OrderMgmt -->|Notificação de Venda| Seller

    %% Fluxo de Pagamento e Financeiro
    OrderMgmt -->|Solicitação| Finance
    Finance <-->|Autorização / Captura| PaymentGateway
    Finance -->|"Cálculo de Comissões (Fee Rules)"| Finance

    %% Persistência Detalhada
    Auth -->|"user, customer, address"| DB
    Catalog -->|"product, variant, category"| DB
    OrderMgmt -->|"orders, order_item (snapshots)"| DB
    Finance -->|"payment, settlement, applied_fee"| DB
```

### Diagrama Conceitual - dbdiagram.io

![Diagrama conceitual](./docs/conceitual/ecommerce-conceitual.svg)

Documentação adicional com informações das tabelas disponível em:
![Documentação do diagrama conceitual](https://dbdocs.io/luis.coelho.761/ecommerce-conceitual)

## Modelo Entidade-Relacionamento

![MER](./docs/mer/marketplace_eer.svg)

Documentação em HTML com informações do MER, comentários das tabelas e suas respectivas colunas
![Documentação do diagrama conceitual](https://dbdocs.io/luis.coelho.761/ecommerce)