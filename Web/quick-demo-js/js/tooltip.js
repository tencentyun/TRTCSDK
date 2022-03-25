const btn = document.getElementById('inviteBtn');
btn.addEventListener('mouseleave', clearTooltip);
btn.addEventListener('blur', clearTooltip);

function clearTooltip(e) {
  e.currentTarget.setAttribute('class', 'invite-btn');
  e.currentTarget.removeAttribute('aria-label');
}

function showTooltip(elem, msg) {
  elem.setAttribute('class', 'invite-btn tooltipped tooltipped-s');
  elem.setAttribute('aria-label', msg);
}
function fallbackMessage(action) {
  let actionMsg = '';
  const actionKey = action === 'cut' ? 'X' : 'C';
  if (/iPhone|iPad/i.test(navigator.userAgent)) {
    actionMsg = 'No support :(';
  } else if (/Mac/i.test(navigator.userAgent)) {
    actionMsg = `Press ⌘-${actionKey} to ${action}`;
  } else {
    actionMsg = `Press Ctrl-${actionKey} to ${action}`;
  }
  return actionMsg;
}
