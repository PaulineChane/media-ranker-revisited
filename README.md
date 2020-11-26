# MediaRanker Revisited

## At a Glance

- Individual, [stage 2](https://github.com/Ada-Developers-Academy/pedagogy/blob/master/rule-of-three.md#stage-2) project
- Due before class, *Tuesday December 1st*
- Submit this project with a PR

## Learning Goals

- Practice using OAuth in a web application
- Practice using Session variables to track a user across multiple HTTP requests
- Add tests to controllers to verify controller logic
- Practice defining rules to govern _authorization_ in a webapp

## Objective

We are providing you with an implementation of MediaRanker. Use this MediaRanker to begin this project.

Our MediaRanker web app was a wonderful website with two major flaws:
1. the way we implemented user login is extremely insecure
1. our controllers are untested

In this assignment you will modify Media Ranker in two ways:
1. our web app can securely **authenticate** multiple users via OAuth and **authorize** them to view, manage and vote on works
1. our controllers will finally have tests that test controller logic

Build your project using _branches_, with at least _one branch_ per wave.  As you finish a wave merge the changes into the main branch. Submit one pull request at the end once you are complete to submit the project.

**Provided Tests**
We have provided controller tests (commented out) for the `UsersController` which you can use, or adapt for your use.  We have similarly commented out fields in the fixtures which could be useful when you have implemented Oauth.

## Implementation Requirements

### Wave 1: Authentication via OAuth

Following the steps in the Textbook curriculum, add OAuth to your Media Ranker Application and enable a user to log in using GitHub.

#### Requirements

- Add all necessary gems and configuration
- Repurpose the existing login functionality to now be a single log in button (on home page or nav bar)
- The log in button shall turn in to a log out button when the user is logged in
- All other requirements from in-class notes apply:
  - Managed via `session`
  - `UsersController`
  - `User` model

### Optional Wave 2: Controller Tests on `upvote` and `UsersController`

- Add tests around logging in functionality using OAuth mocks
- Add tests around logging out functionality using OAuth mocks
- Add tests to the `WorksController` `upvote` action using OAuth mocks
  - Be sure to test nominal and edge cases

### Optional Wave 3: Basic Authorization (Page Access)

Create and test authorization logic to enforce rules that govern what pages on the site users and guests (unauthenticated users) can view.

#### Terminology

- Guest user: a user who is not logged in
- Main page: the page with the spotlight and top 10 items accessed by `localhost:3000` and marked as `root_path`

#### Requirements

As a **guest user**, I want to be able to...

  - access the main page without an error message
  - access the index page should be redirected to the main page with an error message
  - access the show page for any work should be redirected to the main page with an error message

... so that I can see parts of the website, but know that I must log-in for full functionality

As a **logged-in user**, I want to be able to...

  - access the show page for any work of any category
  - access the show page for any index page

... so that I can use full site functionality as a site member

#### Testing Requirements

Ensure that you have updated all relevant `WorksController` tests around authentication using mocks

### Optional Wave 4: Advanced Authorization (Ownership)

Create advanced authorization logic to enforce rules that govern what _changes_ users can make to the site's data. The rules here are more complex than for accessing pages:
- Guests cannot change any data on the site
- All logged-in users can add new works to the site
  - Those works are owned by the user that created them
- The user who owns a given work can:
  - Edit that work
  - Delete that work

#### Tasks
- Modify the edit and delete functionality to ensure that users can only change works they are associated with.
  - Consider how this could be implemented at the model layer.
- Do some research into how to use Google or another OAuth provider for authentication and use that provider.

## What Instructors Are Looking For

Check out the [feedback template](feedback.md) which lists the items instructors will be looking for as they evaluate your project.
