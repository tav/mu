`µ` is a JavaScript micro-framework with a focus on simplicity and performance.

### API

#### `µ.State`

Immutable data structures as supported by [mori] and [Immutable.js] are great.  
But unfortunately they are rather cumbersome to use.

#### `µ.config`

Use this function to read or update the µ internal settings. It can be called  
with a key/value pair to update the current settings, e.g.

```js
µ.config('APIBase', 'https://example.com/api')
```

Or with an object to update multiple keys, e.g.

```js
µ.config({
  APIBase: 'https://example.com/api',
  CDNServers: ['https://cdn.example.com']
})
```

Or with just a key to get the current value for a single setting, e.g.

```js
servers = µ.config('CDNServers')
```

### FAQ

#### Is it any good?

[Yes](http://news.ycombinator.com/item?id=3067434).

#### How do I type µ?

The global variable `mu` is provided as a convenient alias. Should you wish to  
use the unicode variable:

* On OS X, you can get it by pressing '⌥' and 'm' on Apple English keyboards.
* On iOS, you need to enable the Greek keyboard.

For those who are hardcore, you can just copy-paste the variable :wink:

#### How do I pronounce µ?

To be consistent when talking to others about this framework, please pronounce
it as [/ˈmjuː/].

### License

Public domain.

—  
Enjoy, tav <<tav@espians.com>>


[Immutable.js]: http://facebook.github.io/immutable-js/
[mori]: http://swannodette.github.io/mori/
[/ˈmjuː/]: https://upload.wikimedia.org/wikipedia/commons/8/84/En-us-mu.ogg
