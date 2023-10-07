1. Docker container providing toolchain for c++ projects like XO
2. Container prepared using nix.dockerTools.buildLayeredImage.
   - doesn't contain unnecessary bulk
   - layers chosen automatically to promote sharing


# build/update instructions

1.
```
$ cd ~/proj/docker-xo-builder  # directory containing this file
$ nix build
```

2.
upload to docker
```
$ docker load <~/proj/docker-xo-builder/result
```

2a.
Note: to publish container to github, need a personal access token:

- on github.com/${myusername}:
  - visit profile (upper rhs or github.com)
    - developer settings (bottom of sidebar)
      - personal access tokens
        - tokens (classic)
          'generate a personal access token'

          scopes needed:
          - read:packages
          - write:packages
          - delete:packages

2b.
```
$ export CR_PAT=${token}
$ echo $CR_PAT | docker login ghcr.io -u rconybea --password-stdin
Login Succeeded
```

3.
tag image the way github expects,  i.e. format ghcr.io/${username}/${imagename}:${tag}
(tag should match `outputs.docker_builder_deriv.tag` in `flake.nix`)

```
$ docker image tag docker-xo-builder:v1 ghcr.io/rconybea/docker-xo-builder:v1
```

4.
push to github container registry:
```
$ docker image push ghcr.io/rconybea/docker-xo-builder:v1
The push refers to repository [ghcr.io/rconybea/docker-xo-builder]
...omitted...
v1: digest: sha256:e1aad3df64c1ea2ed6674b354e22e3807a831bb8229fa3be399c21f87ea72cb6 size: 6192
```

5.
verify it's arrived by inspecting the gihub 'packages' tab [https://github.com/Rconybea?tab=packages]

image (github package) is initially private;  make it public from the package's 'setting' link

for example workflow using this image, see [https://github.com/rconybea/docker-action-example3]

To test container locally:
```
docker run -i docker-xo-builder:v1 bash
```
