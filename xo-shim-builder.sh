echo "xo-shim-builder.sh: enter"
echo "out=${out}"

set -e

# assemble PATH from buildInputs, nativeBuildInputs
unset PATH
for p in ${buildInputs} ${nativeBuildInputs}; do
    export PATH=${p}/bin/${PATH:+:}${PATH}
done

mkdir -p ${out}/etc
# just write something
touch ${out}/etc/xo-shim-builder-done
