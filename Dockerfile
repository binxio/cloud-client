FROM python:3.9


RUN apt-get update && \
    apt-get install -y curl lsb-release gnupg apt-utils wget unzip && \
    curl -sS --fail -L https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && \
    apt-get install -y curl vim apt-transport-https nano jq git groff nginx zip httpie google-cloud-sdk && \
    rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip install --upgrade pip && \
    pip install awscli cfn-flip cfn-lint yamllint yq boto3 configparser && \
    curl -o /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v3.10.0/gomplate_linux-amd64 && \
    chmod +x /usr/local/bin/gomplate &&  \
    ln -s /usr/local/bin/yq /usr/local/bin/aws /usr/local/bin/cfn-flip /usr/local/bin/cfn-lint /usr/bin


RUN echo "source /usr/lib/google-cloud-sdk/completion.bash.inc" >> .bashrc && \
    echo "complete -C $(which aws_completer) aws" >> .bashrc && \
    mkdir -p $HOME/.vim/pack/tpope/start && \
    git clone https://tpope.io/vim/sensible.git $HOME/.vim/pack/tpope/start/sensible && \
    vim -u NONE -c "helptags sensible/doc" -c q && \
    mkdir -p $HOME/.vim/colors && \
    curl -sS --fail -L -o $HOME/.vim/colors/basic-dark.vim https://raw.githubusercontent.com/zcodes/vim-colors-basic/master/colors/basic-dark.vim && \
    echo "include /usr/share/nano/*" > $HOME/.nanorc

RUN git clone https://github.com/tfutils/tfenv.git /usr/lib/tfenv  && \
    ln -s /usr/lib/tfenv/bin/* /usr/bin/ && \
    /usr/bin/tfenv install 0.12.17 && \
    /usr/bin/tfenv install 1.2.0 && \
    /usr/bin/tfenv use 1.2.0

ARG NODE_VERSION=16.15.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    . $HOME/.nvm/nvm.sh && \
    nvm install v$NODE_VERSION \
    rm -rf $HOME/.nvm
     

ENV PATH=/bin/versions/node/v$NODE_VERSION/bin:$PATH
RUN npm install -g aws-cdk


ARG EKSCTL_VERSION=0.97.0
RUN curl -sSL "https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}/eksctl_$(uname -s)_amd64.tar.gz" | tar -xz -C /usr/bin

RUN curl -sSL https://github.com/coder/code-server/releases/download/v4.4.0/code-server-4.4.0-linux-amd64.tar.gz | \
    tar -xzf - --strip 1 -C /usr/bin

COPY assets/  /var/www/html/assets/
COPY index.html.tmpl /opt/instruqt/
COPY docker-entrypoint.sh /opt/instruqt/
COPY show-versions /usr/local/bin/
RUN  /usr/local/bin/show-versions

ENV PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/bin/versions/node/v$NODE_VERSION/bin



ENTRYPOINT [ "/opt/instruqt/docker-entrypoint.sh" ]
