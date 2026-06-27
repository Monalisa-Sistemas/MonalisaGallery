# CLAUDE.md — Monalisa Gallery

Biblioteca Flutter de componentes UI reutilizaveis para os sistemas da familia Monalisa.
Nao possui app executavel. E consumida via path ou Git por outros projetos Flutter.

## Estrutura do projeto

```
lib/
  monalisa_gallery.dart        # unico ponto de export publico
  src/
    buttons/
      monalisa_buttons.dart    # MButton, MIconButton, MActionButton, MToggleButton
    feedback/
      monalisa_alert.dart      # MAlert, MNotificationCard
      monalisa_confirm_dialog.dart  # MConfirmDialog
      monalisa_loading_overlay.dart # MLoadingOverlay
      monalisa_tooltip.dart    # MToolTip
    inputs/
      monalisa_inputs.dart     # MTextInput, MMaskedTextInput, MNumberInput,
                               # MCurrencyInput, MDateInput, MDateRangeInput,
                               # MDropdown, MSearchInput, MFileInput, MPhotoPicker
      monalisa_numpad.dart     # MNumPad, MNumPadMode, MNumPadResult
    layout/
      monalisa_generic_dialog.dart  # MGenericDialog
      monalisa_layout.dart     # MFieldAction
      monalisa_tab_widget.dart # MTabWidget, MTabWidgetItem
    selection/
      monalisa_selection.dart  # MCheck, MSwitchToggle, MStatusToggle
    theme/
      monalisa_colors.dart     # MonalisaTheme, MonalisaColors
```

## Regras ao adicionar um novo componente

1. Crie o arquivo em `lib/src/<categoria>/monalisa_<nome>.dart`.
2. Adicione o export em `lib/monalisa_gallery.dart`.
3. Adapte imports que referenciem outros projetos (ex: `monalisapdv`) para usar
   recursos internos da biblioteca (`MonalisaColors`, `MButton`, etc.).
4. Documente o novo componente no `README.md`:
   - Adicione entrada no Sumario.
   - Crie a secao `###` com descricao, exemplos de uso e tabela de propriedades.
   - Adicione o nome na lista da secao **API publica**.
5. Nao altere componentes existentes a nao ser que seja explicitamente solicitado.

## Categorias e onde colocar novos componentes

| Categoria  | Pasta           | Exemplos ja existentes                        |
|------------|-----------------|-----------------------------------------------|
| Botoes     | `buttons/`      | MButton, MIconButton, MActionButton           |
| Feedback   | `feedback/`     | MAlert, MConfirmDialog, MLoadingOverlay       |
| Inputs     | `inputs/`       | MTextInput, MDropdown, MPhotoPicker, MNumPad  |
| Layout     | `layout/`       | MGenericDialog, MTabWidget, MFieldAction      |
| Selecao    | `selection/`    | MCheck, MSwitchToggle, MStatusToggle          |
| Tema/cores | `theme/`        | MonalisaTheme, MonalisaColors                 |

## Convencoes de propriedades

Todos os componentes seguem o mesmo vocabulario de props:

- `label` — rotulo visivel acima do campo ou texto do botao
- `hintText` — placeholder
- `enabled` — habilita/desabilita
- `required` — exibe indicador `*`
- `expanded` — largura total disponivel
- `loading` — indicador de carregamento manual
- `backgroundColor` / `foregroundColor` — cores customizadas
- `activeColor` — cor de estado ativo em toggles/checks
- `onPressed` / `onChanged` / `onSubmitted` — callbacks padrao

## Dependencias

- `google_fonts` — tipografia (Inter)
- `file_picker` — selecao de arquivos desktop/web
- `image_picker` — camera e galeria mobile
- `syncfusion_flutter_datepicker` — seletores de data
- `mask_text_input_formatter` — mascaras de input
- `intl` — formatacao de moeda e datas

Nao adicione dependencias sem necessidade clara. Prefira recursos nativos do Flutter.

## Versionamento

O projeto usa tags Git no padrao `vMAJOR.MINOR.PATCH` publicadas no repositorio
[Monalisa-Sistemas/MonalisaGallery](https://github.com/Monalisa-Sistemas/MonalisaGallery)
(branch `main`) no GitHub.

**Ultima tag publicada:** `v0.3.1`

### Fluxo apos cada alteracao ou novo componente

1. Commitar as mudancas normalmente na branch `main`.
2. Publicar a branch atualizada:
   ```
   git push origin main
   ```
3. Criar e publicar a nova tag incrementando o PATCH:
   ```
   git tag v0.3.2
   git push origin v0.3.2
   ```

### Regra de incremento de versao

| Tipo de alteracao                                   | O que incrementar |
|-----------------------------------------------------|-------------------|
| Novo componente ou nova propriedade publica         | MINOR (0.X.0)     |
| Correcao de bug, ajuste visual, refatoracao         | PATCH (0.0.X)     |
| Quebra de compatibilidade com projetos consumidores | MAJOR (X.0.0)     |

### Projetos consumidores

Projetos que usam a biblioteca via Git devem apontar para uma tag especifica no
`pubspec.yaml` para evitar quebras por alteracoes em desenvolvimento:

```yaml
dependencies:
  monalisa_gallery:
    git:
      url: https://github.com/Monalisa-Sistemas/MonalisaGallery.git
      ref: v0.3.1
```

Ao atualizar a biblioteca em um projeto consumidor, troque o `ref` para a nova tag.

## O que nao fazer

- Nao crie um `main.dart` nem app executavel nesta biblioteca.
- Nao importe pacotes de projetos consumidores (ex: `monalisapdv`) dentro de `lib/src/`.
- Nao altere o design ou comportamento de componentes existentes sem autorizacao explicita.
- Nao crie arquivos de documentacao extras alem do `README.md`.
- Nao publique tags sem antes publicar a branch `main`.
