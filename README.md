# atom-gist-dev package

A package to facilitate easy, all-in-one Gist development for non-developers.

This package creates a new top-level menu item named Gist Dev, and offers three
pieces of functionality within that menu.

## Clone a Gist Repository

Once you have forked or created a Gist on GitHub, you are able to copy the HTTPS
clone URL.

![fork_and_copy](https://raw.githubusercontent.com/CenterForAssessment/atom-gist-dev/master/assets/fork_and_copy.gif)

With the URL in your clipboard, open the Gist Dev menu and select the **Clone a
Gist Repository** item. You will then be presented with an input field where you
can paste the URL copied from GitHub. Click the Clone button or press enter, and
the repository will be cloned to your computer.

Atom will then open the directory it created in a new window and you can begin
editing files.

**Note:** By default, the files will be copied to your `/tmp` directory. You can
change the directory that will be used in the settings for this package.

## Save Changes

Any time you want to save your progress, open the Gist Dev menu and select the
**Save Changes** item. This will commit your changes to the source control system,
which means your project can be restored to its current state at any point in
the future.

## Save Changes and Share on GitHub

If you're happy with your changes and would like to share them with others, use
the **Save Changes and Share on GitHub** item under the Gist Dev menu. This will
commit your changes just like the Save Changes menu item, but will also send
your changes back up to GitHub. Once your changes have been sent, a link to view
your page on https://nciea-gist-viewer.herokuapp.com/ will be put in your clipboard.

Open a browser and paste in the URL to see your creation come to life!
