# Contributing

All code contributions - including those of people having commit access - must go through a pull request and approved by a core developer before being merged. This is to ensure proper review of all the code.

We truly ❤️ pull requests!

## How to Start?

If you are worried or don’t know where to start, check out our next section explaining what kind of help we could use and where can you get involved. You can reach out with questions to [Eldad Fux (@eldadfux)](https://twitter.com/eldadfux) or [@appwrite_io](https://twitter.com/appwrite_io) on Twitter, and anyone from the [Appwrite team on Discord](https://discord.gg/GSeTUeA). You can also submit an issue, and a maintainer can guide you!

## Code of Conduct

Help us keep Appwrite open and inclusive. Please read and follow our [Code of Conduct](https://github.com/appwrite/appwrite/blob/master/CODE_OF_CONDUCT.md).

## Submit a Pull Request 🚀

Branch naming convention is as following 

`TYPE-ISSUE_ID-DESCRIPTION`

example:
```
doc-548-submit-a-pull-request-section-to-contribution-guide
```

When `TYPE` can be:

- **feat** - is a new feature
- **doc** - documentation only changes
- **cicd** - changes related to CI/CD system
- **fix** - a bug fix
- **refactor** - code change that neither fixes a bug nor adds a feature

**All PRs must include commit message with the changes description!** 

For the initial start, fork the project and use git clone command to download the repository to your computer. A standard procedure for working on an issue would be to:

1. `git pull`, before creating a new branch, pull the changes from upstream. Your master needs to be up to date.
```
$ git pull
```
2. Create new branch from `master` like: `doc-548-submit-a-pull-request-section-to-contribution-guide`<br/>
```
$ git checkout -b [name_of_your_new_branch]
```
3. Work - commit - repeat ( be sure to be in your branch )

4. Push changes to GitHub 
```
$ git push origin [name_of_your_new_branch]
```

6. Submit your changes for review
If you go to your repository on GitHub, you'll see a `Compare & pull request` button. Click on that button.
7. Start a Pull Request
Now submit the pull request and , click on `Create pull request`.
6. Get a code review approval / reject
7. After approval, merge your PR
8. GitHub will automatically delete the branch, after the merge is done. (they can still be restored).

## Tutorials

From time to time, our team will add tutorials that will help contributors find their way in the Appwrite source code. Below is a list of currently available tutorials:

* [Getting Started for Flutter](https://appwrite.io/docs/getting-started-for-flutter) (Official)
* [Appwrite secure open-source backend server for Flutter example app](https://dev.to/netfirms/appwrite-and-flutter-example-app-42ce)

## Videos

* [Introducing Appwrite for Flutter](https://www.youtube.com/watch?v=KNQzncq10CI) (online meetup with [@eldadfux](https://github.com/eldadfux))
* [Appwrite - Overview with installation (Windows)](https://youtu.be/cJonzmJkPlQ)
* [Appwrite - Services](https://youtu.be/if8f_Bf-Hlw)
* [Overview and installation on Windows](https://youtu.be/cJonzmJkPlQ)
* [Appwrite + Flutter EP00: Series Introduction](https://www.youtube.com/watch?v=eYXb_xbUjio)
* [Appwrite + Flutter EP01: Setup Appwrite](https://www.youtube.com/watch?v=teUUt4ZqIvI)
* [Appwrite + Flutter EP02: Wireframing](https://www.youtube.com/watch?v=RjE0tmyBdow)
* [Appwrite + Flutter EP03: New Flutter project, UI designs](https://www.youtube.com/watch?v=HvcemJhSeE8)
* [Appwrite + Flutter EP04: Let's Authenticate Users](https://www.youtube.com/watch?v=WcGQDmuwGMM)
* [Appwrite + Flutter EP05: Proper State management & Routing and navigation setup](https://www.youtube.com/watch?v=kYpwnYY9Gf8)
* [Appwrite + Flutter EP06: Routing, profile, logout](https://www.youtube.com/watch?v=4ZSX0VSg4bM)
* [Appwrite + Flutter EP07: Querying and Listing Transactions](https://www.youtube.com/watch?v=X9vw4PGDbGc)
* [Appwrite + Flutter EP08: Create, Read, Update, Delete Operations](https://www.youtube.com/watch?v=1HodtTldSdA)
* [Appwrite + Flutter EP09: Searching, ordering and filtering documents](https://www.youtube.com/watch?v=bcG7G-1QBOk)
* [Appwrite + Flutter EP10: Deploying Appwrite Server in VPS + Tips for Appwrite in Production](https://www.youtube.com/watch?v=WzHdvLItrEc)
* [Appwrite + Flutter EP11: User preferences and Locale API](https://www.youtube.com/watch?v=qKkgXy3H7Mw)
* [Appwrite + Flutter EP12: Storage, uploading files, image previews](https://www.youtube.com/watch?v=CNjvNNYWgGU)

## Other Ways to Help

Pull requests are great, but there are many other areas where you can help Appwrite. 

### Blogging & Speaking

Blogging, speaking about, or creating tutorials about one of Appwrite’s many features. Mention [@appwrite_io](https://twitter.com/appwrite_io) on Twitter and/or email team [at] appwrite [dot] io so we can give pointers and tips and help you spread the word by promoting your content on the different Appwrite communication channels. Please add your blog posts and videos of talks to our [Awesome Appwrite](https://github.com/appwrite/awesome-appwrite) repo on GitHub.

### Presenting at Meetups

Presenting at meetups and conferences about your Appwrite projects. Your unique challenges and successes in building things with Appwrite can provide great speaking material. We’d love to review your talk abstract/CFP, so get in touch with us if you’d like some help!

### Sending Feedbacks & Reporting Bugs

Sending feedback is a great way for us to understand your different use cases of Appwrite better. If you had any issues, bugs, or want to share about your experience, feel free to do so on our GitHub issues page or at our [Discord channel](https://discord.gg/GSeTUeA).

### Submitting New Ideas

If you think Appwrite could use a new feature, please open an issue on our GitHub repository, stating as much information as you can think about your new idea and it's implications. We would also use this issue to gather more information, get more feedback from the community, and have a proper discussion about the new feature.

### Improving Documentation

Submitting documentation updates, enhancements, designs, or bug fixes. Spelling or grammar fixes will be very much appreciated.

### Helping Someone

Searching for Appwrite on Discord, GitHub or StackOverflow and helping someone else who needs help. You can also help by reaching others how to contribute to Appwrite's repo!
