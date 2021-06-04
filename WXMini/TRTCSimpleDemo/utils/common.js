export  function randomUserID() {
  return new Date().getTime().toString(16).split('').reverse().join('')
}
export  function randomRoomID() {
  return parseInt(Math.random() * 9999)
}
