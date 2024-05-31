{
  self,
  config,
  ...
}: let
  protoPath = "${config.devenv.root}/otlp/proto";
in {
  scripts.sync-protobufs.exec = ''
    rm -rf "${protoPath}"
    mkdir -p "${protoPath}"

    # Find all .proto files and copy them while preserving the directory structure
    find "${self.inputs.otlp-protobufs}" -name '*.proto' | while IFS= read -r file; do
        # Get the relative path of the file
        relative_path="''${file#${self.inputs.otlp-protobufs}/}"
        echo "Copying $relative_path"

        # Create the necessary directory structure in the destination
        mkdir -p "${protoPath}/$(dirname "$relative_path")"

        # Copy the .proto file to the destination
        cp "$file" "${protoPath}/$relative_path"
    done
  '';
}
