from xonsh.tools import register_custom_style

bold = 'bold #ffffff'
white = '#ffffff'
grey = '#dddddd'
dark = '#bbbbbb'
darker = '#999999'
reddish = '#ffe7e7'
yellowish = '#ffffe7'
greenish = '#e7ffe7'
blueish = '#e7e7ff'

orange = '#ff7700'
pink = '#ffc0cb'
fuchsia = '#f700ff'

t184256 = {
    'Comment.Single': darker,
    #'Escape': pink,
    #'Generic': pink,
    'Token.Keyword': bold,
    'Keyword.Constant': bold,
    'Keyword.Contant': bold,  # sic
    'Keyword.Declaration': bold,
    'Keyword.Namespace': bold,
    'Keyword.Reserved': bold,
    #'Keyword.Type': fuchsia,
    #'Literal': fuchsia,
    #'Literal.Date': fuchsia,
    'Literal.Number': grey,
    'Literal.Number.Bin': grey,
    'Literal.Number.Float': grey,
    'Literal.Number.Hex': grey,
    'Literal.Number.Integer': grey,
    'Literal.Number.Oct': grey,
    'Literal.String': grey,
    'Literal.String.Affix': darker,
    'Literal.String.Backtick': grey,
    'Literal.String.Delimiter': darker,
    'Literal.String.Double': grey,
    'Literal.String.Escape': darker,
    'Literal.String.Heredoc': grey,
    'Literal.String.Interpol': darker,
    'Literal.String.Other': grey,
    'Literal.String.Regex': grey,
    'Literal.String.Single': grey,
    'Name.Builtin': '',  # valid command + situations like /nonex/ls, so, disabled
    #'Name.Builtin.Pseudo': pink,
    'Name.Constant': grey,   # valid absolute path at the start of the command
    'Name.Decorator': darker,
    'Name.Exception': reddish,
    'Name.Namespace': '',  # python module names, valid or not
    #'Name.Other': pink,
    #'Name.Property': orange,
    'Name.Variable': '',
    'Name.Variable.Class': '',
    'Name.Variable.Global': '',
    'Name.Variable.Instance': '',
    'Name.Variable.Magic': '',
    'Operator.Word': bold,  # stuff like `in`, `is`...
    #'Other': pink,
    #'Punctuation': pink,
    #'Text': pink,
    #'Token': fuchsia,
    #'Token.Token': fuchsia,
    #'Token.Generic': fuchsia,
    'Token.Name': '',  # incompletely typed command, valid first path, python lvalue
    'Token.Operator': '',  # also, pathsep in invalid paths if first token
    'Token.Text': '',  # something undecided yet; argument that ain't a file
    #'DEFAULT': grey,
}

register_custom_style('t184256', t184256)
del register_custom_style
$XONSH_COLOR_STYLE="t184256"

$LS_COLORS = {}
for k in ('pi', 'do', 'bd', 'cd', 'so'):
    $LS_COLORS[k] = (yellowish,)
for k in ('ow', 'tw', 'su', 'sg'):
    $LS_COLORS[k] = (orange,)
for k in ('ca', 'mh'):  # IDK what are those
    $LS_COLORS[k] = (fuchsia,)
#$LS_COLORS['rs'] = (white,)  # messes up normal color, IDK what is this
#$LS_COLORS['no'] = (white,)      # normal text
$LS_COLORS['fi'] = (white,)      # normal file
$LS_COLORS['di'] = (white,)     # directory
$LS_COLORS['st'] = (white,)     # directory with a sticky bit set
$LS_COLORS['ex'] = (greenish,)  # executable
$LS_COLORS['ln'] = (white,)     # symlink
$LS_COLORS['mi'] = (reddish,)   # target of an orphaned symlink
$LS_COLORS['or'] = (reddish,)   # orphaned symlink
$EXA_COLORS = 'reset:' + $(echo $LS_COLORS).strip()
$EXA_COLORS += ':' + ':'.join([f'{x}=38;5;188' for x in (
  'ur', 'uw', 'ux', 'ue', 'gr', 'gw', 'gx', 'tr', 'tw', 'tx',  # perm bits
  'sn', 'sb',  # size
  'da',  # timestamp
  'uu', 'gu',  # current user-group
  'lp',  # symlink path
)])
$EXA_COLORS += ':' + ':'.join([f'{x}={val}' for x, val in {
  'un': '38', 'gn': '38',  # non-current user-group
  'ga': '38;5;194',  # git new, greenish
  'gm': '38;5;189',  # git modified, blueish
  'gd': '38;5;224',  # git deleted, reddish
  'gv': '38;5;230',  # git renamed, yellowish
  # git type changed (modified metadata) is untouched
  'df': '38;5;230',  # major device id, yellowish
  'ds': '38;5;230',  # minor device id, yellowish
}.items()])

del bold, white, grey, dark, darker
del reddish, yellowish, greenish, blueish
del orange, pink, fuchsia

$DYNAMIC_CWD_ELISION_CHAR = '…'

$PTK_STYLE_OVERRIDES = {
  'completion-menu': 'bg:black ansibrightblack',
  'completion-menu.completion': 'ansibrightblack',
  'completion-menu.completion.current': 'bg:ansibrightblack grey',
}

#$XONSH_GITSTATUS_HASH = ':'
$XONSH_GITSTATUS_BRANCH = '{#555}'
$XONSH_GITSTATUS_OPERATION = '{#fff}'
$XONSH_GITSTATUS_STAGED = '{BOLD_#0f0}~'
$XONSH_GITSTATUS_CONFLICTS = '{BOLD_#f00}!'
$XONSH_GITSTATUS_CHANGED = '{#fff}±'
$XONSH_GITSTATUS_UNTRACKED = '{#555}…'
$XONSH_GITSTATUS_STASHED = '{#fff}#'
$XONSH_GITSTATUS_CLEAN = '{#555}='
$XONSH_GITSTATUS_AHEAD = '{#fff}+'
$XONSH_GITSTATUS_BEHIND = '{#fff}-'

