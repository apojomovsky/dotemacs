# em: start server if needed, open a new frame, stay quiet
function em {
  setsid -f emacsclient -a "" -n -c "$@" >/dev/null 2>&1 </dev/null
}

function emt {
  emacsclient -a "" -t "$@" 2>/dev/null
}