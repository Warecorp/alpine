node {
    def alpine38

    docker.withRegistry('', 'dockerwc') {

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

    alpine38 = docker.build("warecorpdev/alpine:3.8-${env.BUILD_ID}", "--build-arg ALPINE_VER=3.8 .")

    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from alpine38
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('', 'dockerwc') {
            alpine38.push("warecorpdev/alpine:3.8-${env.BUILD_ID}")
            alpine38.push("latest")
        }
    }
  }
}