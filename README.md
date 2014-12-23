### Purpose and scope

Media ebuilds.

### Contributing

* proper Copyright header
* license should be GPL-2
* all commits MUST be gpg-signed
* always provide a metadata.xml with contact information

### Adding the overlay

With paludis: see [Paludis repository configuration](http://paludis.exherbo.org/configuration/repositories/index.html)

With layman:
```layman -f -o https://raw.github.com/hasufell/media-overlay/master/repository.xml -a media-overlay```

### Signature verification

All commits on the first parent (at least) are signed by me.
You can verify the repository via:
```
[ -z "$(git show -q --pretty="format:%G?" $(git rev-list --first-parent master) | grep -v G)" ] && echo "verification success" || echo "verification failure"
```

If the verification failed, you can examine which commits did
via
```
git show -q --pretty="format:%h %an %G?" $(git rev-list --first-parent master) | grep '.* [NBU]$'
```
