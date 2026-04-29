# AppBusao (Rio Bus Tracker)

O **AppBusao** é um aplicativo desenvolvido em Flutter para o acompanhamento em tempo real da frota de ônibus (SPPO) na cidade do Rio de Janeiro. Ele permite que os usuários visualizem a localização exata dos veículos no mapa, facilitando o planejamento de viagens e a espera nos pontos.

## 🚀 Funcionalidades

- **Mapa Interativo**: Visualização dos ônibus sobre o OpenStreetMap.
- **Filtro por Linha**: Selecione uma linha específica para visualizar apenas os ônibus correspondentes.
- **Atualização em Tempo Real**: O app busca novos dados automaticamente a cada 30 segundos.
- **Dados Detalhados**: Processamento de informações como ordem do veículo, velocidade e última atualização.

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev) - Framework de UI.
- [flutter_map](https://pub.dev/packages/flutter_map) - Renderização de mapas.
- [http](https://pub.dev/packages/http) - Requisições à API.
- [intl](https://pub.dev/packages/intl) - Formatação de datas e horas.
- [latlong2](https://pub.dev/packages/latlong2) - Cálculos e tipos geográficos.

## ⚙️ Como Funciona

### Integração com a API
O aplicativo consome os dados da API pública de mobilidade da Prefeitura do Rio de Janeiro:
`https://dados.mobilidade.rio/gps/sppo`

### Processamento de Dados
- **Tratamento de Coordenadas**: A API do Rio retorna latitude e longitude como strings usando vírgulas como separadores decimais (ex: `-22,81948`). O app converte esses valores para o formato double padrão.
- **Filtragem Temporal**: Para garantir dados recentes, o app solicita posições dentro do intervalo do último minuto (`dataInicial` e `dataFinal`).
- **Desduplicação**: O sistema identifica cada ônibus pelo seu número de ordem e exibe apenas a posição mais recente recebida, evitando poluição visual no mapa.

## 📦 Como Executar

1. **Pré-requisitos**:
   - Flutter SDK instalado.
   - Emulador Android/iOS ou dispositivo físico conectado.

2. **Instalação**:
   ```bash
   # Clone o repositório
   git clone https://github.com/seu-usuario/rio_bus_tracker.git

   # Entre na pasta do projeto
   cd rio_bus_tracker

   # Instale as dependências
   flutter pub get
   ```

3. **Execução**:
   ```bash
   flutter run
   ```

---
