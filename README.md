# vibelist
> Ruby on Rails back end API for vibelist, an application for creating Spotify playlists in the genre & mood of the user's choice. 

Vibelist is powered by the Spotify web API and the Spotify Web Player SDK to provide the user with an elegant, fun and useful tool for creating Spotify playlists in a certain mood and genre. Users can log in through Spotify's 3rd party authorization and create multiple playlists, listen to them in the browser and save them to their Spotify account for later use.

Front end Javascript & React app repo available here: https://github.com/slowbeam/vibe-list-client

##

![vibelist demo 1](https://github.com/slowbeam/vibe-list-client/blob/master/public/demos/v-demo-1.gif)

## Installation

OS X & Linux:

```sh
bundle install
```

## Usage example

Vibelist can create dynamic playlists through the user's selection of up to 3 genres and a mood:

![vibelist demo 2](https://github.com/slowbeam/vibe-list-client/blob/master/public/demos/v-demo-2.gif)

Vibelist can play individual songs, or full playlists created with the app in the browser:

![vibelist demo 3](https://github.com/slowbeam/vibe-list-client/blob/master/public/demos/v-demo-3.gif)

Vibelist can save playlists to your Spotify account:

![vibelist demo 4](https://github.com/slowbeam/vibe-list-client/blob/master/public/demos/v-demo-4.gif)

## Development setup

The vibelist API is built using postgreSQL. Please install postgreSQL on your computer before attempting to load the API on your local server. 

```sh
rails db:create
rails db:migrate
rails s
```


## Release History

* 0.1.0
    * First official release
   


## Meta

Sandy Edwards – [@sedwardscode](https://twitter.com/sedwardscode) – sedwardscode@gmail.com

[https://github.com/slowbeam](https://github.com/slowbeam)

## Contributing

1. Fork it (<https://github.com/slowbeam/vibe-list-server/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
