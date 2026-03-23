String ensureJsonExtension(String filename, {String extension = '.json'}) {
  if (filename.toLowerCase().endsWith(extension.toLowerCase())) {
    return filename;
  }
  return '$filename$extension';
}
