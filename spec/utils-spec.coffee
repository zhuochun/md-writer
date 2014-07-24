utils = require "../lib/utils"

describe "utils", ->
  it "get posts path without token", ->
    expect(utils.getPostsDir("_posts/")).toEqual("_posts/")

  it "get posts path with tokens", ->
    date = utils.getDate()
    expected = utils.getPostsDir("_posts/{year}/{month}")
    expect(expected).toEqual("_posts/#{date.year}/#{date.month}")

  it "get date dashed string", ->
    date = utils.getDate()
    expect(utils.getDateStr()).toEqual("#{date.year}-#{date.month}-#{date.day}")
