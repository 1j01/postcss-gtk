
# postcss-gtk

Processes GTK+ CSS into browser CSS
with [PostCSS](https://github.com/postcss/postcss)

See the [demo](http://1j01.github.io/elementary.css/demo/) of
[elementary.css](http://github.com/1j01/elementary.css)

## Usage

`postcss-gtk` exports a [`Processor`][Processor],
so you can call [`use`][use] and [`process`][process] on it,
or you can [`use`][use] it in another [`Processor`][Processor]

[Processor]: https://github.com/postcss/postcss/blob/master/docs/api.md#processor-class
[use]: https://github.com/postcss/postcss/blob/master/docs/api.md#processoruseplugin
[process]: https://github.com/postcss/postcss/blob/master/docs/api.md#processorprocesscss-opts
