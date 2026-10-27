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
- Funciona standalone com permissão ACE ou integrado ao vRP, com detecção automática.
- Validação de permissão, solicitação pendente, assinatura PNG e tamanho de até 8 MiB no recebimento.

## Dependências

- FiveM com suporte a Lua 5.4.
- [screenshot-basic](https://github.com/citizenfx/screenshot-basic).

O vRP é opcional. A integração usa `Passport`, `HasGroup` e `lib/Utils.lua`. Em bases vRP, as notificações usam o evento `Notify` com a assinatura presente no código. No modo standalone, usam notificações nativas do GTA V, sem recurso de interface adicional.

## Instalação

1. Coloque a pasta `rvt_carfoto` dentro dos recursos do servidor. Mantenha a subpasta `fotos`.
2. Escolha o modo e configure a permissão em `config.lua`.
3. Adicione ao `server.cfg`:

```cfg
ensure screenshot-basic
ensure rvt_carfoto
```

### Standalone

Sem vRP iniciado, `Framework = "auto"` usa ACE. Para forçar esse modo mesmo em uma base vRP, configure `Framework = "standalone"`.

Conceda a permissão ao grupo administrativo:

```cfg
add_ace group.admin rvt_carfoto.use allow
```

Seu jogador precisa pertencer a esse grupo. Exemplo de associação pelo identificador de licença, substituindo `SUA_LICENSE` pela licença do administrador:

```cfg
add_principal identifier.license:SUA_LICENSE group.admin
```

Sem a permissão ACE, o comando é negado. A verificação usa o sistema de [ACL nativo do FiveM](https://docs.fivem.net/docs/cookbook/2021/07/17/quick-note-on-using-built-in-acl-security/).

### Com vRP

Inicie o vRP antes do Carfoto:

```cfg
ensure vrp
ensure screenshot-basic
ensure rvt_carfoto
```

Com `Framework = "auto"`, um recurso `vrp` iniciado tem prioridade: o acesso continua pelo grupo e nível de `Permission`. ACE não contorna uma negativa do vRP.

Use `Framework = "vrp"` para exigir essa integração. Nesse modo, a ausência do vRP bloqueia o comando. Se o vRP estiver iniciado e a integração falhar, o acesso também é bloqueado, sem liberar pela ACE. Confira o console e a compatibilidade da base.

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

- `Framework`: `auto` (padrão), `vrp` ou `standalone`.
- `Permission`: `Group` e `Level` para vRP (padrão: `Admin`, nível `1`); `Ace` para standalone (padrão: `rvt_carfoto.use`).
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
