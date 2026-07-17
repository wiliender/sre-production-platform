module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-${var.environment}"

  cidr = "10.0.0.0/16" #Tamanho da rede

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

# ==============================================================================
# ZONAS DE DISPONIBILIDADE - AZs (us-east-1a, us-east-1b, us-east-1c)
# ==============================================================================
# Definimos o uso de 3 Zonas de Disponibilidade distintas para garantir a 
# Alta Disponibilidade (High Availability) e Tolerância a Falhas da infraestrutura.
#
# O que isso significa na prática?
#
# 1. Isolamento Físico e de Infraestrutura:
#    Cada AZ (como 'us-east-1a') representa um ou mais datacenters físicos separados, 
#    com sistemas de energia, refrigeração e redes de dados totalmente independentes.
#    Eles são interconectados por redes de altíssima velocidade e baixíssima latência.
#
# 2. Tolerância a Desastres (Tolerância a Falhas):
#    Ao distribuirmos nossas subnets e recursos nessas 3 AZs, garantimos que se 
#    um desastre físico acontecer na AZ 'us-east-1a' (ex: queda total de energia 
#    ou incêndio no datacenter):
#    - As outras duas zonas ('us-east-1b' e 'us-east-1c') continuarão funcionando.
#    - O Kubernetes (EKS) detectará a falha e moverá nossos Pods automaticamente
#      para os nós sobreviventes das AZs ativas.
#    - O tráfego continuará fluindo sem interrupções para os usuários.
#
# 3. Requisito de Produção para EKS:
#    A AWS exige o uso de subnets distribuídas em pelo menos 2 Zonas de 
#    Disponibilidade para provisionar o Control Plane do EKS. Adotar 3 Zonas é 
#    o padrão da indústria para arquiteturas resilientes e de nível de produção.
# ==============================================================================

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  # ==============================================================================
  # SUBNETS PRIVADAS (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
  # ==============================================================================
  # IMPORTANTE: É aqui que o coração do nosso cluster EKS (Kubernetes) vai bater.
  # Nenhum recurso nesta camada possui um IP público ou pode ser acessado diretamente 
  # pela internet, garantindo a segurança máxima da nossa infraestrutura.
  #
  # Aqui ficam alocados:
  #
  # 1. Nodes (Instâncias EC2 / Workers):
  #    As máquinas físicas ou virtuais gerenciadas pelo EKS que dão poder de 
  #    processamento ao cluster. Elas ficam isoladas do mundo externo e só se 
  #    comunicam de forma privada com o control plane do EKS.
  #
  # 2. Pods (Os containers da sua aplicação):
  #    As menores unidades de execução do Kubernetes. Eles ganham IPs privados 
  #    dentro dessa faixa de subnets graças ao plugin de rede da AWS (VPC CNI). 
  #    Toda a comunicação leste-oeste (entre microserviços) acontece aqui de forma 
  #    totalmente protegida.
  #
  # 3. Serviços Internos (Bancos de dados, Redis, Filas):
  #    Qualquer recurso de apoio que não precise de exposição externa (ex: RDS, 
  #    ElastiCache) deve rodar restrito a essa camada privada, comunicando-se 
  #    apenas com as aplicações autorizadas dentro do cluster.
  #
  # Segurança de Saída:
  # Para que os nós e pods consigam atualizar pacotes ou se conectar com APIs externas, 
  # o tráfego de saída deles é roteado de forma segura através do NAT Gateway 
  # (que fica posicionado lá na Subnet Pública).
  # ==============================================================================

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  # ==============================================================================
  # SUBNETS PÚBLICAS (10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24)
  # ==============================================================================
  # IMPORTANTE: Nunca coloque Nodes (servidores/máquinas de trabalho) do Kubernetes aqui.
  # Esta camada serve apenas como "porta de entrada" e saída controlada da VPC.
  #
  # Aqui ficam apenas os seguintes componentes:
  #
  # 1. ALB (Application Load Balancer):
  #    O balanceador de carga público. Ele recebe todo o tráfego que vem da internet
  #    (como requisições HTTP/HTTPS dos usuários) e o direciona de forma segura 
  #    para as subnets privadas (onde rodam os nossos pods/nodes).
  #
  # 2. NAT Gateway:
  #    O "tradutor de endereços" de saída. Ele permite que os nossos Nodes e Pods
  #    na rede privada acessem a internet (para baixar atualizações, pacotes ou 
  #    falar com APIs externas), mas impede que qualquer pessoa de fora consiga
  #    iniciar uma conexão direta com as nossas máquinas privadas.
  #
  # 3. Bastion Host (se necessário):
  #    Um servidor "ponte" extremamente seguro. Ele serve como o único ponto de 
  #    acesso SSH para que os administradores/SREs possam se conectar na VPC e,
  #    a partir dele, acessar os servidores privados para fins de manutenção.
  # ==============================================================================

  enable_nat_gateway = true

# ==============================================================================
# CONFIGURAÇÃO DO NAT GATEWAY (enable_nat_gateway = true)
# ==============================================================================
# O NAT Gateway é o "tradutor de saída" para os nossos recursos na camada privada.
# Ele é o componente crítico que viabiliza a existência e operação do EKS.
#
# Entendendo o Fluxo de Rede:
#
# SEM NAT Gateway (Cenário de Falha):
#   [Private Subnet/Nodes] -> (Sem saída para internet) -> Falha ao baixar imagens do Docker Hub/ECR
#   Resultado: Os Pods travam em "ErrImagePull" ou "ImagePullBackOff" e o cluster não funciona.
#
# COM NAT Gateway (Cenário de Produção Correto):
#   [Private Subnet/Nodes] -> [NAT Gateway (Subnet Pública)] -> [Internet] -> Imagens Docker baixadas com sucesso!
#   Resultado: O Control Plane do Kubernetes consegue gerenciar os nós e os Pods sobem perfeitamente.
#
# Considerações de SRE para Produção:
# 1. Segurança Unidirecional:
#    O NAT Gateway permite que as instâncias dentro da subnet privada iniciem conexões 
#    para a internet (para atualizar pacotes ou acessar APIs externas), mas impede de forma 
#    absoluta que qualquer agente externo na internet inicie uma conexão direta com os nossos Nodes.
#
# 2. Alta Disponibilidade (HA) vs Custos:
#    - Em Produção (prod): Recomenda-se um NAT Gateway por Zona de Disponibilidade (AZ) para 
#      evitar que a queda de uma AZ isole as outras subnets privadas.
#    - Em Desenvolvimento (dev): Geralmente usamos apenas um único NAT Gateway compartilhado 
#      (single_nat_gateway = true) para economizar custos de infraestrutura da AWS.
# ==============================================================================

  single_nat_gateway = true

  enable_dns_hostnames = true

  enable_dns_support = true

# ==============================================================================
# CONFIGURAÇÃO DE DNS DA VPC
# ==============================================================================
# enable_dns_support   = true  => Ativa o resolvedor de DNS interno da AWS (AmazonProvidedDNS).
# enable_dns_hostnames = true  => Garante que instâncias com IPs públicos ganhem nomes de host DNS públicos.
#
# Ambas as configurações são OBRIGATÓRIAS e CRÍTICAS para o funcionamento do EKS:
#
# 1. Kubernetes & CoreDNS:
#    O CoreDNS dentro do Kubernetes depende diretamente do resolvedor DNS da VPC 
#    para conseguir encaminhar requisições que precisam resolver nomes fora do 
#    cluster (ex: APIs externas, conexões de banco de dados, downloads de pacotes).
#    Sem o DNS da AWS habilitado, a resolução de nomes interna do cluster quebra.
#
# 2. AWS Load Balancer Controller:
#    Este controller gerencia e cria os nossos ALBs/NLBs automaticamente a partir 
#    dos recursos de Ingress do Kubernetes. Ele precisa dessas flags de DNS 
#    ativas para registrar, comunicar e associar corretamente as rotas e os 
#    endpoints privados das instâncias aos balanceadores de carga da AWS.
# ==============================================================================

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

# ==============================================================================
# Pode criar Load Balancer nesta subnet.
# Pode criar Load Balancer interno.
# Sem essas tags o EKS não consegue provisionar ALBs automaticamente.
# ==============================================================================

}