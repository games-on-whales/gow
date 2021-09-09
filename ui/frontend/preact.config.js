import util from 'util';
import TsConfigPathsPlugin from 'tsconfig-paths-webpack-plugin';

export default {
    webpack(config, env, helpers, options) {
        if (!config.resolve.plugins) {
            config.resolve.plugins = [];
        }
        config.resolve.plugins.push(
            new TsConfigPathsPlugin()
        );

        // don't include the hash in the output filename (this is for easier
        // compatibility with wails)
        config.output.filename = '[name].js';

        // Do the same for the CSS file
        const cssPlugins = helpers.getPluginsByName(config, 'MiniCssExtractPlugin');
        if (cssPlugins.length > 0) {
            if (cssPlugins.length > 1) {
                console.warn("Found more than one CSS plugin; assuming the first");
            }

            cssPlugins[0].plugin.options.filename = '[name].css';
        }

        for (let loader of helpers.getLoadersByName(config, 'file-loader')) {
            loader.rule.options = {
                name: 'assets/inc/[name].[ext]'
            }
        }

        // We only want 1 chunk (again for Wails)
        config.optimization.splitChunks = {
            minChunks: 1,
            cacheGroups: {
                default: false
            }
        }

        // The default config treats all CSS files under `src/components` as
        // CSS modules, and no CSS files in other locations as modules. I
        // prefer to specify which files are modules (by naming them
        // `*.module.css`) and allow them in any source folder.
        const [ moduleRule, nonModuleRule ] =
            helpers.getRulesByMatchingFile(config, 'foo.css');

        moduleRule.rule.include = /\.module.css$/;
        nonModuleRule.rule.exclude = /\.module.css$/;

        helpers
            .getLoadersByName(config, 'postcss-loader')
            .forEach(({ loader }) => {
                const opts = loader.options.postcssOptions;
                let overrideBrowserslist;

                const ap = opts.plugins.filter(({ postcssPlugin: name }) => name === 'autoprefixer');
                if (ap.length) {
                    ({ overrideBrowserslist } = ap[0].options);
                }

                opts.plugins = [
                    require('postcss-preset-env')({
                        autoprefixer: {
                            overrideBrowserslist
                        },
                        stage: 0
                    })
                ];
            });
    },
}
