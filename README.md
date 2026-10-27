# RVT Carfoto

**Fotografia de veículos para FiveM, com fundo transparente.**

Um comando cria uma cópia local do veículo em um estúdio, ajusta a câmera e a iluminação e captura a imagem. O recorte roda na NUI, usando Canvas, e o PNG é salvo na pasta do recurso no servidor.

Feito para preparar imagens de catálogos, garagens e divulgação sem posicionar cada carro manualmente.

## Recursos

- Captura individual ou em lote, com até 30 modelos por comando.
- Três enquadramentos: frente, traseira e lateral.
- Remoção do fundo magenta, recorte automático e margem ao redor do veículo.
- Largura máxima de saída configurável, com padrão de 1600 px e sem ampliar a captura original.
- Iluminação, campo de visão e posição do estúdio configuráveis.
- Acesso por grupo e nível no vRP.
- Validação de permissão, solicitação pendente, assinatura PNG e tamanho de até 8 MiB no recebimento.

## Dependências

- FiveM com suporte a Lua 5.4.
- vRP com `Passport`, `HasGroup` e `lib/Utils.lua`.
- [screenshot-basic](https://github.com/citizenfx/screenshot-basic).
- Evento `Notify` compatível com as chamadas em `client.lua` e `server.lua`.

O recurso usa essas interfaces específicas do vRP. Bases com outras versões precisam adaptar as chamadas de permissão e notificação.

## Instalação

1. Coloque a pasta `rvt_carfoto` dentro dos recursos do servidor. Mantenha a subpasta `fotos`.
2. Confira o grupo e o nível em `config.lua`.
3. Adicione ao `server.cfg`, após as dependências:

```cfg
ensure vrp
ensure screenshot-basic
ensure rvt_carfoto
```

## Uso

No jogo, com a permissão configurada:

```text
/fotocarro sultan
/fotocarro sultan traseira
/fotocarro elegy lado
/fotocarro sultan elegy adder frente
```

Use o nome de spawn de um veículo disponível no servidor. Fique parado até o processamento terminar.

As imagens ficam em `rvt_carfoto/fotos/<spawn>.png`. Uma nova captura do mesmo modelo substitui o arquivo anterior, inclusive quando outro ângulo é escolhido.

## Configuração

As opções estão em `config.lua`:

- `Permission`: grupo e nível exigidos. Padrão: `Admin`, nível `1`.
- `Command`: nome do comando. Padrão: `fotocarro`.
- `Folder`: pasta de saída dentro do recurso. Crie a pasta antes de usar um caminho diferente.
- `OutputWidth`: largura máxima do PNG. Padrão: `1600`.
- `Studio`: coordenadas e orientação do veículo.
- `Lighting`: intensidade das luzes principal, de preenchimento, superior e de recorte. Use `0` para desligar uma luz.
- `DefaultAngle`: `frente`, `traseira` ou `lado`.
- `Fov`: campo de visão da câmera. Padrão: `28.0`.

## Como funciona

O servidor verifica a permissão e envia os modelos ao cliente. Cada veículo é criado localmente, fora da área jogável, com câmera e luzes próprias. O `screenshot-basic` captura a cena; a NUI remove o fundo, recorta a imagem e devolve o PNG ao servidor para gravação.

O recorte usa cor de fundo. Pinturas magenta e reflexos próximos dessa cor podem perder detalhes. Resolução do jogo, texturas e configurações gráficas também influenciam o resultado.

## Estrutura

```text
rvt_carfoto/
├── client.lua       # Estúdio, câmera e captura
├── config.lua       # Permissões e ajustes
├── fxmanifest.lua   # Manifest do recurso
├── server.lua       # Comando, validação e gravação
├── ui/index.html    # Recorte e exportação com Canvas
└── fotos/           # Imagens geradas, ignoradas pelo Git
```

## Autor

**RVT Scripts | Revoltz**

GitHub: [revoltzgod](https://github.com/revoltzgod)

Discord: `Revoltz`

Site: [rvtscripts.com](https://rvtscripts.com)
