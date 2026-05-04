# Auditoria da Extracao Inicial

Este projeto foi extraido de outro app e continha componentes reutilizaveis misturados com componentes acoplados ao sistema original.

## Problemas encontrados

- Nao havia `pubspec.yaml`, `lib/` nem barrel exportavel, entao outro projeto nao conseguiria depender desta pasta como pacote Flutter.
- Varios imports ainda apontavam para `package:monalisapdv/...` ou caminhos relativos inexistentes, como `../../../ui/theme/app_colors.dart`.
- As propriedades tinham nomes inconsistentes: `text`, `texto`, `caption`, `label`, `isEnabled`, `fgColor`, `bgColor`, `tabOnEnter`, `enterPressed`.
- Alguns componentes genericos disparavam regras de negocio do projeto antigo, como alertas de produto, caixa, operadores, impressao e comandos do PDV.
- Havia widgets duplicados ou sobrepostos, como botoes primarios, outlined, action buttons, close buttons e duas estrategias de dropdown.
- Campos tinham defaults obrigatorios demais para design system, especialmente cores que deveriam vir do `ThemeData`.

## Padrao adotado

- API publica em `lib/monalisa_gallery.dart`.
- Prefixo visual `M` preservado para continuidade.
- Nomes de propriedades padronizados em ingles tecnico:
  - `label` para rotulo visivel.
  - `hintText` para placeholder.
  - `enabled`, `required`, `expanded`, `loading` para flags.
  - `backgroundColor` e `foregroundColor` para cores opcionais.
  - `onChanged`, `onSubmitted`, `onPressed` para callbacks.
  - `controller` e `focusNode` para controle externo.
- Componentes novos dependem de tema por padrao e aceitam sobrescrita por parametro quando necessario.

## Arquivos acoplados removidos

- `inputs/m_input_box.dart`: continha comandos, navegacao, venda, impressao, providers e servicos do PDV.
- `buttons/m_select_user_button.dart`: dependia de modelos de caixa, operadores, banco e estado do app antigo.
- `menus/menu_config.dart`: dependia de enum externo do app.
- `tab_control/tab_view_widget.dart`: dependia de servico de teclado e alerts do app antigo.
- `utils/AppUtils.dart`: misturava validacao, dialogs, icones de pagamento e dependencias circulares com componentes.
- `inputs/m_cb_formapag.dart`: representava uma escolha de forma de pagamento especifica do dominio do PDV.
- `inputs/m_search_input.dart`: tinha validacao e texto de busca de produto.
- `inputs/m_logo_select.dart`: importava botoes pelo pacote antigo `monalisapdv`.
- `inputs/m_text_input.dart`: dependia de `AppUtils` do projeto antigo para mascara de CPF/CNPJ.
- `inputs/m_number_input.dart`: dependia de alerts e tema importados do pacote antigo `monalisapdv`.

Os arquivos historicos de referencia foram removidos do pacote inicial. A API consumivel por outro projeto fica exclusivamente em `lib/monalisa_gallery.dart`.
