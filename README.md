# Monalisa Gallery

Biblioteca Flutter local com componentes reutilizaveis para os sistemas da familia Monalisa.

O objetivo da `monalisa_gallery` e padronizar visual, comportamento, nomes de propriedades e estados de componentes usados em telas ERP, CRUDs, formularios e fluxos administrativos.

## Sumario

- [Instalacao](#instalacao)
- [Tema e cores](#tema-e-cores)
- [Convencoes da biblioteca](#convencoes-da-biblioteca)
- [Inputs de texto](#inputs-de-texto)
- [Inputs numericos, datas e arquivos](#inputs-numericos-datas-e-arquivos)
  - [MNumPad](#mnumpad)
- [Dropdowns e selecoes](#dropdowns-e-selecoes)
- [Botoes](#botoes)
- [Toggles](#toggles)
- [Alertas](#alertas)
- [Dialogs](#dialogs)
- [Tooltips](#tooltips)
- [Imagens](#imagens)
- [Layout](#layout)
  - [MTabWidget](#mtabwidget)
- [Boas praticas](#boas-praticas)

## Instalacao

### Uso local por path

No `pubspec.yaml` do projeto consumidor:

```yaml
dependencies:
  monalisa_gallery:
    path: ../MONALISA_GALLERY
```

Depois rode:

```powershell
flutter pub get
```

Importe em qualquer arquivo Dart:

```dart
import 'package:monalisa_gallery/monalisa_gallery.dart';
```

### Uso por repositorio Git

Quando a biblioteca estiver em um repositorio Git:

```yaml
dependencies:
  monalisa_gallery:
    git:
      url: https://github.com/seu-usuario/monalisa_gallery.git
      ref: v0.1.0
```

Use tags como `v0.1.0`, `v0.2.0` etc. para evitar que projetos consumidores quebrem com alteracoes em desenvolvimento.

## Tema e cores

A biblioteca foi feita para respeitar o `ThemeData` do app consumidor. A cor principal dos componentes vem de `Theme.of(context).colorScheme.primary`.

Exemplo basico:

```dart
MaterialApp(
  theme: MonalisaTheme.light(
    primary: const Color(0xFF4F9BD8),
  ),
  home: const MinhaTela(),
);
```

Tambem e possivel sobrescrever cores em componentes especificos usando `backgroundColor`, `foregroundColor`, `activeColor` ou propriedades equivalentes.

### MonalisaColors

Use `MonalisaColors` quando precisar das cores padrao da biblioteca:

```dart
Container(
  color: MonalisaColors.surfaceSoft,
  child: const Text('Conteudo'),
);
```

Cores disponiveis:

- `primary`
- `primaryDark`
- `secondary`
- `secondaryLight`
- `danger`
- `success`
- `warning`
- `surface`
- `surfaceSoft`
- `text`
- `textMuted`
- `border`

## Convencoes da biblioteca

Os componentes seguem nomes padronizados:

- `label`: texto visivel acima do campo ou texto principal do componente.
- `hintText`: placeholder do campo.
- `enabled`: controla estado habilitado/desabilitado.
- `required`: mostra indicador visual de obrigatoriedade.
- `expanded`: faz o botao ocupar toda a largura disponivel.
- `loading`: mostra carregamento manual.
- `backgroundColor`: cor de fundo customizada.
- `foregroundColor`: cor do texto/icone customizada.
- `activeColor`: cor ativa em componentes booleanos.
- `onPressed`: callback de botao.
- `onChanged`: callback de alteracao de valor.
- `onSubmitted`: callback ao enviar um campo.
- `controller`: controle externo de texto.
- `focusNode`: controle externo de foco.

Os componentes desabilitados usam cursor `forbidden` quando aplicavel e buscam manter contraste suficiente para leitura.

## Inputs de texto

### MTextInput

Campo de texto padrao para formularios.

```dart
final nomeController = TextEditingController();

MTextInput(
  label: 'Nome',
  hintText: 'Informe o nome',
  controller: nomeController,
  required: true,
  onChanged: (value) {
    print(value);
  },
);
```

Principais propriedades:

- `label`: rotulo do campo.
- `hintText`: placeholder.
- `controller`: `TextEditingController`.
- `focusNode`: `FocusNode`.
- `onChanged`: chamado ao digitar.
- `onSubmitted`: chamado ao finalizar edicao.
- `onTap`: chamado ao clicar no campo.
- `enabled`: habilita/desabilita.
- `readOnly`: bloqueia edicao mantendo o campo ativo.
- `required`: mostra `*`.
- `obscureText`: campo de senha.
- `autoFocus`: foco automatico.
- `nextFocusOnSubmit`: envia foco para o proximo campo.
- `maxLength`: limite de caracteres.
- `maxLines`: quantidade de linhas.
- `backgroundColor`: fundo customizado.
- `foregroundColor`: texto customizado.
- `keyboardType`: tipo de teclado.
- `inputFormatters`: formatadores.
- `suffixIcon`: icone/acao no final do campo.

### Campo de senha

```dart
MTextInput(
  label: 'Senha',
  hintText: 'Digite a senha',
  obscureText: true,
  required: true,
);
```

Quando `obscureText` e `true`, o componente mostra o botao de visualizar/ocultar senha.

### Campo com varias linhas

```dart
MTextInput(
  label: 'Observacoes',
  hintText: 'Digite observacoes internas...',
  maxLines: 4,
  maxLength: 500,
);
```

Quando `maxLines > 1` e `maxLength` e informado, o componente mostra contador interno no canto inferior direito. Exemplo: `120/500`. Ao atingir o limite, mostra `500/max.`.

### Campo desabilitado

```dart
MTextInput(
  label: 'Codigo',
  controller: TextEditingController(text: '123'),
  enabled: false,
);
```

Use para visualizacao de cadastro, auditoria ou campos bloqueados por permissao.

### MMaskedTextInput

Campo com mascara simples baseada em `#` para numeros.

```dart
MMaskedTextInput(
  label: 'CPF',
  hintText: '000.000.000-00',
  mask: '###.###.###-##',
  onChanged: (value) {},
);
```

Principais propriedades:

- `label`
- `mask`
- `controller`
- `onChanged`
- `enabled`
- `required`
- `hintText`

## Inputs numericos, datas e arquivos

### MNumberInput

Campo numerico para quantidade, percentual ou valores simples.

```dart
MNumberInput(
  label: 'Quantidade',
  decimalPlaces: 0,
  maxValue: 999,
  onChanged: (value) {
    print(value);
  },
);
```

Quando `decimalPlaces` e `0`, o componente mostra setas para incrementar/decrementar em 1.

Principais propriedades:

- `label`
- `initialValue`
- `onChanged`
- `enabled`
- `autoFocus`
- `decimalPlaces`
- `maxValue`
- `suffixText`
- `hintText`

### MCurrencyInput

Campo de moeda formatado por locale.

```dart
MCurrencyInput(
  label: 'Valor',
  initialValue: 149.90,
  symbol: 'R$',
  locale: 'pt_BR',
  onChanged: (value) {},
);
```

Principais propriedades:

- `label`
- `initialValue`
- `onChanged`
- `controller`
- `enabled`
- `autoFocus`
- `locale`
- `symbol`

### MDateInput

Campo de data individual com seletor visual Syncfusion.

```dart
MDateInput(
  label: 'Data de nascimento',
  initialDate: DateTime.now(),
  onChanged: (date) {},
);
```

Principais propriedades:

- `label`
- `initialDate`
- `onChanged`
- `controller`
- `enabled`

### MDateRangeInput

Campo de periodo com inicio e fim.

```dart
MDateRangeInput(
  label: 'Periodo',
  initialStartDate: DateTime(2026, 1, 1),
  initialEndDate: DateTime(2026, 1, 31),
  onChanged: (start, end) {},
);
```

Principais propriedades:

- `label`
- `initialStartDate`
- `initialEndDate`
- `onChanged`
- `enabled`

### MFileInput

Campo para selecao de arquivo.

```dart
MFileInput(
  label: 'Documento',
  allowedExtensions: const ['pdf', 'png', 'jpg'],
  onChanged: (path) {},
);
```

Principais propriedades:

- `label`
- `controller`
- `onChanged`
- `allowedExtensions`
- `enabled`
- `required`
- `placeholder`

### MSearchInput

Campo de busca com icone.

```dart
MSearchInput(
  hintText: 'Buscar clientes...',
  onChanged: (value) {},
  onSubmitted: () {},
);
```

Principais propriedades:

- `hintText`
- `controller`
- `focusNode`
- `onChanged`
- `onSubmitted`
- `autoFocus`

### MNumPad

Teclado virtual reutilizavel para preencher qualquer campo conectado a um `TextEditingController`.

O componente abre em overlay, pode ser movido pelo usuario, destaca o campo em edicao com `targetKey` e possui dois modos:

- `MNumPadMode.numeric`: teclado numerico.
- `MNumPadMode.text`: teclado completo com numeros, letras em padrao QWERTY, espaco e backspace.

#### Uso basico

```dart
final codigoController = TextEditingController();

MTextInput(
  label: 'Codigo',
  controller: codigoController,
);

MButton.outlined(
  label: 'Abrir teclado',
  icon: Icons.dialpad_rounded,
  onPressed: () {
    MNumPad.show(
      context,
      controller: codigoController,
    );
  },
);
```

#### Com highlight no campo preenchido

Use uma `GlobalKey` no campo alvo e passe essa chave em `targetKey`.

```dart
final codigoController = TextEditingController();
final codigoFieldKey = GlobalKey();

MTextInput(
  key: codigoFieldKey,
  label: 'Codigo do cliente',
  controller: codigoController,
  keyboardType: TextInputType.number,
);

MButton.outlined(
  label: 'NumPad',
  icon: Icons.dialpad_rounded,
  onPressed: () {
    MNumPad.show(
      context,
      controller: codigoController,
      targetKey: codigoFieldKey,
      title: 'Codigo numerico',
    );
  },
);
```

#### Abrir em modo texto

Por padrao, o teclado abre em modo numerico. Para abrir diretamente com letras:

```dart
MNumPad.show(
  context,
  controller: codigoController,
  targetKey: codigoFieldKey,
  initialMode: MNumPadMode.text,
);
```

Para forcar o modo numerico:

```dart
MNumPad.show(
  context,
  controller: codigoController,
  initialMode: MNumPadMode.numeric,
);
```

#### Capturando confirmacao ou cancelamento

```dart
final result = await MNumPad.show(
  context,
  controller: codigoController,
  targetKey: codigoFieldKey,
  initialMode: MNumPadMode.numeric,
);

if (result == MNumPadResult.confirmed) {
  print('Confirmado: ${codigoController.text}');
}

if (result == MNumPadResult.canceled) {
  print('Cancelado');
}
```

#### Parametros

- `controller`: obrigatorio. Campo que recebe o texto digitado.
- `title`: titulo exibido no topo do teclado.
- `targetKey`: chave do widget que deve receber o destaque visual no overlay.
- `initialMode`: modo inicial do teclado. Use `MNumPadMode.numeric` ou `MNumPadMode.text`.
- `onConfirm`: chamado ao confirmar.
- `onCancel`: chamado ao cancelar ou clicar fora do popup.
- `onClear`: mantido por compatibilidade de API.
- `barrierDismissible`: permite cancelar ao clicar fora do teclado.

## Dropdowns e selecoes

### MDropdown

Dropdown moderno com overlay proprio, hover, estado selecionado e abertura para cima quando nao ha espaco abaixo.

```dart
String status = 'Ativo';

MDropdown<String>(
  label: 'Status',
  value: status,
  items: const ['Ativo', 'Inativo', 'Pendente'],
  itemLabel: (item) => item,
  itemIcon: (item) {
    if (item == 'Ativo') return Icons.check_circle_outline;
    if (item == 'Inativo') return Icons.block;
    return Icons.schedule;
  },
  onChanged: (value) {
    status = value;
  },
);
```

Principais propriedades:

- `label`
- `items`
- `value`
- `onChanged`
- `itemLabel`
- `enabled`
- `hintText`
- `maxHeight`
- `itemIcon`

### MCheck

Checkbox padronizado com titulo e descricao.

```dart
bool aceitou = false;

MCheck(
  value: aceitou,
  title: 'Aceitar notificacoes',
  description: 'Exibe avisos importantes no painel inicial.',
  onChanged: (value) {
    aceitou = value;
  },
);
```

Principais propriedades:

- `value`
- `onChanged`
- `title`
- `description`
- `enabled`
- `activeColor`
- `foregroundColor`

### MSwitchToggle

Switch on/off com texto informativo.

```dart
bool ativo = true;

MSwitchToggle(
  value: ativo,
  title: 'Usuario ativo',
  description: 'Controla se o usuario pode acessar o sistema.',
  onChanged: (value) {
    ativo = value;
  },
);
```

Principais propriedades:

- `value`
- `onChanged`
- `title`
- `description`
- `enabled`
- `activeColor`
- `foregroundColor`

### MStatusToggle

Toggle visual para alternar status com label, icone, cor e confirmacao opcional.

```dart
MStatusToggle(
  value: ativo,
  activeLabel: 'Ativo',
  inactiveLabel: 'Inativo',
  activeIcon: Icons.check_circle_outline,
  inactiveIcon: Icons.block,
  activeColor: Colors.green,
  inactiveColor: Colors.blueGrey,
  confirmTitle: 'Alterar status',
  confirmMessage: 'Deseja realmente alterar este status?',
  onChanged: (value) {
    ativo = value;
  },
);
```

Principais propriedades:

- `value`
- `onChanged`
- `activeLabel`
- `inactiveLabel`
- `activeIcon`
- `inactiveIcon`
- `activeColor`
- `inactiveColor`
- `confirmTitle`
- `confirmMessage`
- `confirmText`
- `cancelText`
- `enabled`
- `height`
- `confirmOnActivate`
- `confirmOnDeactivate`

## Botoes

### MButton

Botao principal da biblioteca.

```dart
MButton(
  label: 'Salvar',
  icon: Icons.save,
  onPressed: () {},
);
```

Principais propriedades:

- `label`
- `onPressed`
- `icon`
- `variant`
- `backgroundColor`
- `foregroundColor`
- `expanded`
- `loading`
- `margin`

### MButton.outlined

Botao secundario com borda.

```dart
MButton.outlined(
  label: 'Cancelar',
  icon: Icons.close,
  onPressed: () {},
);
```

### MButton variante texto

```dart
MButton(
  label: 'Ver detalhes',
  icon: Icons.notes,
  variant: MButtonVariant.text,
  onPressed: () {},
);
```

### Loading automatico em callbacks async

Se `onPressed` retorna `Future`, o botao controla loading automaticamente e bloqueia duplo clique.

```dart
MButton(
  label: 'Sincronizar',
  icon: Icons.cloud_sync_outlined,
  onPressed: () async {
    await Future.delayed(const Duration(seconds: 2));
  },
);
```

### Loading manual

```dart
MButton(
  label: 'Carregando',
  loading: true,
  onPressed: () {},
);
```

### MIconButton

Botao compacto de icone.

```dart
MIconButton(
  icon: Icons.add,
  tooltip: 'Adicionar',
  onPressed: () {},
);
```

Tambem controla loading automatico quando `onPressed` e async.

```dart
MIconButton(
  icon: Icons.cloud_sync_outlined,
  tooltip: 'Sincronizar',
  onPressed: () async {
    await Future.delayed(const Duration(seconds: 2));
  },
);
```

Principais propriedades:

- `icon`
- `onPressed`
- `tooltip`
- `backgroundColor`
- `foregroundColor`
- `size`
- `loading`

### MActionButton

Botao de acao pequeno, bom para tabelas, cards e linhas de registro.

```dart
MActionButton(
  icon: Icons.delete_outline,
  tooltip: 'Excluir',
  danger: true,
  onPressed: () {},
);
```

Principais propriedades:

- `icon`
- `onPressed`
- `tooltip`
- `danger`
- `backgroundColor`
- `foregroundColor`

## Toggles

### MToggleButton

Selecao segmentada de uma unica opcao por vez.

```dart
String status = 'Complete';

MToggleButton(
  value: status,
  items: const ['Complete', 'Incomplete', 'Pending'],
  onSelected: (value) {
    status = value;
  },
);
```

Principais propriedades:

- `items`: lista de opcoes.
- `onSelected`: retorna a opcao selecionada.
- `value`: valor selecionado controlado externamente.
- `backgroundColor`: cor do item selecionado.
- `foregroundColor`: cor do texto do item selecionado.
- `enabled`: habilita/desabilita.

## Alertas

### MLoadingOverlay

Overlay de carregamento para bloquear uma tela, card ou area enquanto uma acao esta em andamento.

```dart
MLoadingOverlay(
  isLoading: carregando,
  title: 'Processando',
  description: 'Aguarde enquanto os dados sao atualizados.',
  child: MinhaTelaOuCard(),
);
```

Principais propriedades:

- `isLoading`
- `child`
- `title`
- `description`
- `color`
- `overlayColor`
- `blockInteraction`
- `showCard`
- `borderRadius`
- `minLoadingWidth`: largura minima usada enquanto carrega quando o filho nao define largura.

O titulo e limitado a 1 linha. A descricao e limitada a 2 linhas. Quando o filho nao define altura, o overlay usa a altura necessaria para o card de loading.

### MAlert

Alertas de aplicacao exibidos no topo da tela.

```dart
MAlert.showError(context, 'Nao foi possivel concluir a operacao.');
```

```dart
MAlert.showWarning(context, 'Verifique os dados antes de continuar.');
```

```dart
await MAlert.showSuccess(context, 'Registro salvo com sucesso.');
```

```dart
MAlert.showInfo(
  context,
  title: 'Nova notificacao',
  description: 'Existe uma atualizacao disponivel para analise.',
  icon: Icons.notifications_active_rounded,
  onView: () {
    // Acao do botao Ver.
  },
);
```

Metodos disponiveis:

- `MAlert.showError(BuildContext context, String message)`
- `MAlert.showWarning(BuildContext context, String message)`
- `MAlert.showSuccess(BuildContext context, String message)`
- `MAlert.showInfo(BuildContext context, {required title, required description, icon, onView})`

### MNotificationCard

Card interno de notificacao. Pode ser usado diretamente quando necessario.

```dart
MNotificationCard(
  title: 'Aviso',
  description: 'Mensagem da notificacao.',
  icon: Icons.error,
  iconColor: MonalisaColors.danger,
  onViewPressed: () {},
);
```

Principais propriedades:

- `title`
- `description`
- `icon`
- `iconColor`
- `onViewPressed`

## Dialogs

### MConfirmDialog

Dialog de confirmacao que retorna `bool`.

```dart
final confirmed = await MConfirmDialog.show(
  context,
  title: 'Confirmar exclusao',
  description: 'Deseja realmente excluir este registro?',
  confirmText: 'Excluir',
  cancelText: 'Cancelar',
);

if (confirmed) {
  // Executa a acao.
}
```

Alias proximo do padrao antigo:

```dart
final confirmed = await MConfirmDialog.confirma(
  context,
  'Confirmar operacao',
  'Deseja continuar?',
);
```

Principais propriedades/metodos:

- `title`
- `description`
- `confirmText`
- `cancelText`
- `confirmColor`
- `icon`
- `show(...)`
- `confirma(...)`

## Tooltips

### MToolTip

Tooltip com botao circular de interrogacao. Abre ao passar o mouse ou clicar.

```dart
Row(
  children: const [
    Text('Limite de credito'),
    SizedBox(width: 8),
    MToolTip(
      title: 'Limite de credito',
      description: 'Valor maximo permitido para compras faturadas.',
    ),
  ],
);
```

Principais propriedades:

- `title`
- `description`
- `backgroundColor`
- `foregroundColor`
- `width`

## Imagens

### MPhotoPicker

Seletor de foto com preview.

No Android/iOS, abre bottom sheet com camera e galeria. No Windows, Linux, macOS e Web, usa seletor de arquivos.

```dart
final photoKey = GlobalKey<MPhotoPickerState>();

MPhotoPicker(
  key: photoKey,
  size: 96,
  onChanged: (file) {
    if (file == null) {
      print('Foto removida');
      return;
    }
    print(file.name);
  },
);
```

Abrindo por botao externo:

```dart
MButton.outlined(
  label: 'Selecionar foto',
  icon: Icons.photo_library_outlined,
  onPressed: () => photoKey.currentState?.openPicker(),
);
```

Removendo por botao externo:

```dart
MButton.outlined(
  label: 'Remover foto',
  icon: Icons.close,
  onPressed: () => photoKey.currentState?.clearPhoto(),
);
```

Principais propriedades:

- `onChanged`
- `enabled`
- `size`
- `placeholderIcon`
- `borderColor`
- `placeholderBackgroundColor`
- `openOnTap`
- `showRemoveButton`
- `initialPreviewBytes`

Estado publico:

- `hasPhoto`
- `openPicker()`
- `clearPhoto()`

## Layout

### MTabWidget

Componente de abas com conteudo fixo em altura, icone, label e cores ativas configuraveis por aba.

```dart
MTabWidget(
  contentHeight: 360,
  items: const [
    MTabWidgetItem(
      label: 'Dados',
      icon: Icons.person_outline,
      activeBackgroundColor: Color(0xFF155AA8),
      activeForegroundColor: Colors.white,
      child: Center(child: Text('Conteudo de dados')),
    ),
    MTabWidgetItem(
      label: 'Historico',
      icon: Icons.history,
      activeBackgroundColor: Color(0xFF16A34A),
      activeForegroundColor: Colors.white,
      child: Center(child: Text('Conteudo do historico')),
    ),
  ],
);
```

Principais propriedades do `MTabWidget`:

- `items`: lista obrigatoria de abas.
- `contentHeight`: altura da area exibida pelo `TabBarView`.
- `initialIndex`: indice inicial selecionado.
- `padding`: espacamento externo aplicado ao componente.

Principais propriedades do `MTabWidgetItem`:

- `label`: texto exibido na aba.
- `icon`: icone exibido antes do texto.
- `child`: conteudo renderizado quando a aba estiver selecionada.
- `activeBackgroundColor`: cor de fundo da aba selecionada. O padrao e `Color(0xFF155AA8)`.
- `activeForegroundColor`: cor do texto e do icone quando a aba estiver selecionada. O padrao e `Colors.white`.

### MFieldAction

Wrapper para alinhar botoes ou acoes laterais com o corpo de inputs que possuem `label`.

Use quando um campo e um botao ficarem lado a lado em uma `Row`. Como a label ocupa altura acima do campo, o `MFieldAction` aplica um pequeno deslocamento vertical na acao para manter o botao alinhado com a area digitavel.

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: MTextInput(
        label: 'Codigo',
        hintText: 'Informe o codigo',
      ),
    ),
    const SizedBox(width: 10),
    MFieldAction(
      width: 132,
      child: MButton.outlined(
        label: 'Buscar',
        icon: Icons.search,
        expanded: true,
        onPressed: () {},
      ),
    ),
  ],
);
```

Principais propriedades:

- `child`: botao, icone ou acao lateral.
- `hasFieldLabel`: aplica ou remove o deslocamento da label.
- `labelOffset`: ajuste fino da altura reservada para a label.
- `width`: largura opcional para a acao.

## Exemplo de tela basica

```dart
class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({super.key});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final nomeController = TextEditingController();
  String status = 'Ativo';
  bool ativo = true;

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            MTextInput(
              label: 'Nome',
              controller: nomeController,
              required: true,
            ),
            const SizedBox(height: 16),
            MDropdown<String>(
              label: 'Status',
              value: status,
              items: const ['Ativo', 'Inativo'],
              itemLabel: (item) => item,
              onChanged: (value) {
                setState(() => status = value);
              },
            ),
            const SizedBox(height: 16),
            MSwitchToggle(
              value: ativo,
              title: 'Cliente ativo',
              onChanged: (value) {
                setState(() => ativo = value);
              },
            ),
            const SizedBox(height: 24),
            MButton(
              label: 'Salvar',
              icon: Icons.save,
              expanded: true,
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 600));
                if (!context.mounted) return;
                await MAlert.showSuccess(context, 'Cliente salvo.');
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Boas praticas

- Use `MonalisaTheme.light(primary: ...)` no `MaterialApp`.
- Prefira importar apenas `package:monalisa_gallery/monalisa_gallery.dart`.
- Use `enabled: false` para modo visualizacao em telas de cadastro.
- Use callbacks async diretamente nos botoes; eles controlam loading automaticamente.
- Use `MConfirmDialog` antes de acoes destrutivas.
- Use `MAlert` para feedback rapido apos salvar, excluir, validar ou falhar.
- Use `MDropdown` para listas pequenas e medias.
- Use `MSearchInput` para busca textual.
- Use `MTextInput(maxLines: ..., maxLength: ...)` para observacoes.
- Use `MFieldAction` para alinhar botoes laterais com inputs que possuem label.
- Evite recriar estilos manualmente no app consumidor; primeiro tente propriedades do componente.

## API publica

Todos os exports ficam em:

```dart
lib/monalisa_gallery.dart
```

Componentes exportados:

- Tema: `MonalisaTheme`, `MonalisaColors`
- Inputs: `MTextInput`, `MMaskedTextInput`, `MNumberInput`, `MCurrencyInput`, `MDateInput`, `MDateRangeInput`, `MDropdown`, `MSearchInput`, `MFileInput`, `MPhotoPicker`, `MNumPad`, `MNumPadMode`, `MNumPadResult`
- Botoes: `MButton`, `MButton.outlined`, `MIconButton`, `MActionButton`
- Toggles e selecoes: `MToggleButton`, `MCheck`, `MSwitchToggle`, `MStatusToggle`
- Feedback: `MAlert`, `MNotificationCard`, `MLoadingOverlay`, `MConfirmDialog`, `MToolTip`
- Layout: `MFieldAction`, `MTabWidget`, `MTabWidgetItem`
