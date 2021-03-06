+++
date = "2017-06-23"
title = "Debouncing Redux actions"
[blackfriday]
  smartyPants = false
+++

I recently needed, in a React/Redux application, to draw a timeseries chart with forecasting, based on a selected set of past events.  

One component was the chart that displays the selected past events and a forecast spline, the another one had a list of toggles for past events. Toggling one past event would add or exclude it from the chart and the forecast has to be recalculated.   

In the context of Redux, toggling one past event translates into dispatching an action that updates the state in the Redux store. The components listening for store updates (in my case, the chart) are then re-rendered.

Recalculating an expensive forecast and updating the chart after each toggle was... not the best thing to do. Since everything happens on a single thread in JavaScript (no workers were used), you could not click a second toggle while the forecast was recalculated from the first toggle, the UI would be briefly unresponsive. Annoying, especially on mobile devices.

That's when I remembered about this good guy from Lodash, [debounce](https://lodash.com/docs/#debounce), best described in this [very nice article](https://css-tricks.com/debouncing-throttling-explained-examples/) by the following metaphor:

*Imagine you are in an elevator. The doors begin to close, and suddenly another person tries to get on. The elevator doesn't begin its function to change floors, the doors open again. Now it happens again with another person. The elevator is delaying its function (moving floors), but optimizing its resources.*

The elevator changing floors... that's my forecast computation. The persons trying to get in... actions generated by toggling.

To illustrate the problem here's a small React/Redux app.

{{% pen id="dRRjZM" height="250"%}}

It is as minimal as possible, without the react-redux glue, there are no action constants and creators, the store is a global variable. So don't do this at home. :)

So what do we have here?  

A component that when you move the mouse over it, adds the point coordinates to the Redux store.
{{< highlight jsx >}}
const MoveOverArea = ({ addPoint }) => (
  <div
    className='move-over area'
    onMouseMove={({ clientX, clientY }) => addPoint({
      x: clientX, y: clientY 
    })}
  />
)
{{< /highlight >}}

A component that draws a list of points.
{{< highlight jsx >}}
const CanvasArea = ({ points }) => (
  <svg className='canvas area'>
    {points.map(({ x, y }) => (
      <circle key={`${x}-${y}`} cx={x} cy={y} r="3"/>
    ))} 
  </svg>
 )
{{< /highlight >}}

A container to group them together.
{{< highlight jsx >}}
let i = 0;
const App = ({ points, addPoint, reset }) => (
  <div className='app'>
    <MoveOverArea addPoint={addPoint}/>
    <button onClick={reset}>Reset</button>
    <CanvasArea points={points}/>
    <p>Render count: {i++}</p>
  </div>
)
{{< /highlight >}}

Action dispatchers.
{{< highlight jsx >}}
const reset = () => store.dispatch({
  type: 'RESET'
});

const addPoint = point => store.dispatch({
  type: 'ADD_POINT',
  point
});
{{< /highlight >}}

Reducer. The app state is just a list of points.
{{< highlight jsx >}}
const points = (state = [], action) => {
  switch (action.type) {
    case 'ADD_POINT':
      return [
        ...state,
        action.point
      ]
    case 'RESET':
      return [];
    default:
      return state;
  }
}
{{< /highlight >}}

And the final piece of this minimal React/Redux app, the main entry point where I render the `App` and subscribe to store updates.
{{< highlight jsx >}}
const { createStore } = Redux;
const store = createStore(points);

const render = () => ReactDOM.render(
  <App
    points={store.getState()}
    addPoint={addPoint}
    reset={reset}
  />,
  document.getElementById('app')
);

store.subscribe(render);
render();
{{< /highlight >}}

This is maybe not the best example to illustrate the problem I had, because rendering that SVG each time a point is added is not really an expensive computation, like the forecasting calculation in my real-world problem.  
But the fact that it is small, and has numerous mouse-over triggered actions that do resemble my case with fast consecutive toggles, makes me think it's good enough to prove a point.

## Debounce to the rescue  

The line of thinkining was: I have make less frequent state updates so that the `CanvasArea` is rendered less frequently. Thank you Captain Obvious, right?

It means the app state must not be updated each time a point is added, but only after adding a bunch of them. So there has to be a place to keep the points that have been "mouse-overed" but not yet added to the state.  

Figured the best place for that would be the state local to the `MouseOverArea`. Which does not exist in the above example, since it's a stateless component.  

So we have to refactor it a bit and turn it into a class to make it stateful (it is possible to have local state and yet only work with functional components using [recompose](https://github.com/acdlite/recompose), but that will be an exercise for a future post).

{{< highlight jsx >}}
class MoveOverArea extends React.Component {
  state = { points: [] }
  
  addPoint(point) {
    this.setState({
      points: [
        ...this.state.points,
        point
      ]},
      () => this.props.addPoints(this.state.points)
    );
  }
  
  render() {
    return (
      <div
        className='move-over area'
        onMouseMove={({ clientX, clientY }) => {
          this.addPoint({ x: clientX, y: clientY });
        }}
      />
    )
  }
}
{{< /highlight >}}

This component receives the `addPoints` action dispatcher asa prop instead of `addPoint`. `addPoint` becomes a method that updates the local state with one point, and calls `addPoints` afterwards with all the points in the local state.

The new action dispatcher `addPoints` makes use of our friend, `debounce`, who is kind enough to call the wrapped function (which is like the plural of `addPoint` from the first example) with the same arguments that it receives, at the right time.  The right time in this case is 300 ms after the mouse movement paused.

{{< highlight jsx >}}
const addPoints = _.debounce(
  points => store.dispatch({
    type: 'ADD_POINTS',
    points
  }),
  300
);
{{< /highlight >}}

The reducer changes a bit to add multiple points instead of one:

{{< highlight jsx >}}
const points = (state = [], action) => {
  switch (action.type) {
    case 'ADD_POINTS':
      return [
        ...state,
        ...action.points
      ];
    //...
  }
};
{{< /highlight >}}

And the result:
{{% pen id="MoEVRq" height="250"%}}

The render count has decreased dramatically. Admittedly, it's much nicer to see the points being drawn as you move the mouse like in the first "realtime" version, but that is not the goal here.  

Now, can you spot the bug?

## The bug

There is a small problem with `MoveOverArea`. Clicking Reset would clear the points in the Redux state, but those in its local state are never removed.  

One solution would be to add a callback to the `addPoints` action dispatcher that would reset the local state.

{{< highlight jsx "hl_lines=8 20">}}
this.setState({
  points: [
    ...this.state.points,
    point
  ]},
  () => this.props.addPoints(
    this.state.points,
    () => this.setState({ points: [] })
  )
);

//...

const addPoints = _.debounce(
  (points, cb) => { 
    store.dispatch({
      type: 'ADD_POINTS',
      points
    }, 300);
    cb();
  });
{{< /highlight >}}

Calling `setState` from a callback that can be trigered arbitrarily may be a problem if the component is unmounted in the meantime, because `setState` on an unmounted component is a no-op.

So this other solution may be better, more in line with the "one way data flow" of React:

{{< highlight jsx "hl_lines=3 14 15 16 17 18">}}
const App = ({ points, addPoints, reset }) => (
  <div className='app'>
    <MoveOverArea points={points} addPoints={addPoints}/>
    <button onClick={reset}>Reset</button>
    <CanvasArea points={points}/>
    <p>Render count: {i++}</p>
  </div>
)

//...

class MoveOverArea extends React.Component {
  //...
  componentWillReceiveProps ({ points }) {
    if (points.length !== this.props.points.length ) {
      this.setState({ points });
    }
  }
  //...
}
{{< /highlight >}}

Each time `MouseOverArea` is rendered, it received the points from the Redux state. So compare them with the previously received points and update the local state accordingly.

Bug fixed.
{{% pen id="yXzKrq" height="250"%}}
