+++
date = "2017-05-28"
title = "Estimating running performance - the FP + d3 way"
draft = true
[blackfriday]
  smartyPants = false
+++

I'm a big fan of functional programming and of d3. Not great in any of them, but literate enough to work my way with zipping, composing, "point-free"-ing (without overdoing it), or charting when needed.

I'm also a runner, the nerdy kind who reads running books. One of them is Daniel's Running formula, which has a nice table that compares performances in races ranging from 3000m up to a marathon.

A simplified version of the table looks like this:

| VDOT | 5k | 10k | Halfmarathon | Marathon |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| 30  | 30:40 | Content Cell  | Content Cell  | Content Cell  |
| 40  | 24:08  | Content Cell  | Content Cell  | Content Cell  |
| 50  | 19:57  | Content Cell  | Content Cell  | Content Cell  |
| 60  | 17:03  | Content Cell  | Content Cell  | Content Cell  |

As a runner I had this question: how does a 5k race compare to a marathon?  
If I run, let's say 21:00 in a 5k, what time can I expect to run a marathon in?

