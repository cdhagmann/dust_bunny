# coding: utf-8

require "wasmer"

class AssertionError < RuntimeError
end

def assert &block
  raise AssertionError unless yield
end

module WASM
    class Runner
        def initialize(file)

            file = File.expand_path file, File.dirname(__FILE__)
            wasm_bytes = IO.read(file, mode: "rb")

            # Create a store.
            store = Wasmer::Store.new

            # Let's compile the Wasm module, as usual.
            module_ = Wasmer::Module.new store, wasm_bytes

            # Here we go.
            #
            # First, let's extract the WASI version from the module. Why? Because
            # WASI already exists in multiple versions, and it doesn't work the
            # same way. So, to ensure compatibility, we need to know the version.
            wasi_version = Wasmer::Wasi::get_version module_, true

            # Second, create a `Wasi::Environment`. It contains everything related
            # to WASI. To build such an environment, we must use the
            # `Wasi::StateBuilder`.
            #
            # In this case, we specify the program name is `wasi_test_program`. We
            # also specify the program is invoked with the `--test` argument, in
            # addition to two environment variable: `COLOR` and
            # `APP_SHOULD_LOG`. Finally, we map the `the_host_current_dir` to the
            # current directory. There it is:
            wasi_env =
            Wasmer::Wasi::StateBuilder.new('wasi_test_program')
                .argument('--test')
                .environment('COLOR', 'true')
                .environment('APP_SHOULD_LOG', 'false')
                .map_directory('the_host_current_dir', '.')
                .finalize

            # From the WASI environment, we generate a custom import object. Why?
            # Because WASI is, from the user perspective, a bunch of
            # imports. Consequently `generate_import_object`… generates a
            # pre-configured import object.
            #
            # Do you remember when we said WASI has multiple versions? Well, we
            # need the WASI version here!
            import_object = wasi_env.generate_import_object store, wasi_version

            # Now we can instantiate the module.
            instance = Wasmer::Instance.new module_, import_object

            # The entry point for a WASI WebAssembly module is a function named
            # `_start`. Let's call it and see what happens!
            instance.exports._start.()

            # It has printed:
            #
            # ```
            # Found program name: `wasi_test_program`
            # Found 1 arguments: --test
            # Found 2 environment variables: COLOR=true, APP_SHOULD_LOG=false
            # Found 1 preopened directories: DirEntry("/the_host_current_dir")
            # ```
            #
            # on the standard output.

        end
    end
end
        

