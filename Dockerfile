FROM python:3.7


RUN apt-get update && \
    apt-get install -y curl lsb-release gnupg apt-utils wget unzip && \
    curl -sS --fail -L https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && \
    apt-get install -y curl vim apt-transport-https nano jq git groff nginx zip httpie google-cloud-sdk && \
    rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip install awscli cfn-flip cfn-lint yamllint yq boto3 configparser && \
    curl -o /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v2.7.0/gomplate_linux-amd64 && \
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

ENV TERRAFORM_VERSION=0.12.17
RUN wget --quiet https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ARG NODE_VERSION=10.3.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash && \
    . $HOME/.nvm/nvm.sh && \
    nvm install v$NODE_VERSION \
    rm -rf $HOME/.nvm

ENV PATH=/bin/versions/node/v$NODE_VERSION/bin:$PATH
RUN npm install -g aws-cdk

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /usr/bin

RUN wget https://github.com/cdr/code-server/releases/download/2.1692-vsc1.39.2/code-server2.1692-vsc1.39.2-linux-x86_64.tar.gz -O /tmp/code-server.tar.gz --no-check-certificate && \
    tar -xzf /tmp/code-server.tar.gz --strip 1 -C /usr/bin && \
    rm /tmp/code-server.tar.gz

COPY assets/  /var/www/html/assets/
COPY index.html.tmpl /opt/instruqt/
COPY docker-entrypoint.sh /opt/instruqt/

ENV PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/bin/versions/node/v$NODE_VERSION/bin

ENTRYPOINT [ "/opt/instruqt/docker-entrypoint.sh" ]
