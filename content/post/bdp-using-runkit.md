+++
date = "2017-05-25T11:08:30+03:00"
title = "Hello World powered by BDP and RunKit"

[blackfriday]
  smartyPants = false
+++

How could the first post in a programming blog start with something else then a Hello World variation? It just can't, it would be so wrong...

[RunKit](https://runkit.com) is an online JavaScript playground where you can use about any module available on npm. It's primarily geared towards server-side JS, tough you can work with client-side libraries as well, with some limitations. 

Great for prototyping things. Very cool features, but not going to explore them all in a byte sized post like this one.

Now, you're probably wondering what **BDP** is. Not sure if I coined it or not, but BDP in my book is Behavior Driven Prototyping. Like its better known relative, BDD, we proceed by first writing failing tests, then the prototyped implementation to make tests pass, and repeat these two steps until we are finally pleased. Ok, ok, BDP actually is BDD, it just sounds more misterious.

RunKit is perfectly suited for BDP. And for a dev blog as well, since it's a pleasure to embed it right here.  
So don't be afraid to try things:

 + require [expect](https://github.com/Automattic/expect.js) or your favorite BDD assertion library from npm
 + write a few tests and make them pass
 + don't click the green button if the focus is on the editor, do Shift + Enter, much better

<script src="https://embed.runkit.com" data-element-id="my-element"></script>
<div id="my-element">
const expect = require('expect.js');

// Implementation area
const helloWorld = () => 'your highly creative HW implementation'

// Test area
expect(helloWorld()).to.equal('Hello World!');
expect(helloWorld()).not.to.equal('Goodbye World!');
'success';
</div>

Packages are required just like you would do in any Node program, no need for npm or yarn install. Import is not supported.  

RunKit renders the evaluation of the last expression in the program, so that's why a simple 'success' string at the end. Comment that out and see what you get. :)  

So next time you set your eyes on that NPM package, in most cases there's no need to waste time creating a dev environment just to play with it, RunKit has you covered. And BDP is highly encouraged.