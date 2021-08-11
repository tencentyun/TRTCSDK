const fs = window.nodeRequire('fs')
const path = window.nodeRequire('path')

export function getExampleCode(filePath) {
  let codePath = null;
  if (process.env.NODE_ENV === 'development') {
    codePath = path.join('assets/', filePath)
  } else {
    codePath = path.join(process.resourcesPath, '/app.asar/', 'assets/', filePath)
  }
  return fs.readFileSync(codePath, {encoding: 'utf-8'})
}
