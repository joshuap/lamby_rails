# Lamby Rails: A Rails+Lamby Example App

This app was created by following the official [Lamby Quick Start Guide](https://lamby.custominktech.com/docs/quick_start).

## Links

- https://aws.amazon.com/lambda/
- https://lamby.custominktech.com
- https://lamby.custominktech.com/docs/quick_start
- https://twitter.com/heyjoshwood

## Notes

- Generate the initial Rails app:

    ```sh
    brew install awscli jq
    brew tap aws/tap
    brew install aws-sam-cli

    asdf shell ruby 2.7.1

    gem install rails -N

    rails new lamby_rails \
      --skip-action-mailer --skip-action-mailbox --skip-action-text \
      --skip-active-record --skip-active-storage --skip-puma \
      --skip-action-cable --skip-spring --skip-listen --skip-turbolinks \
      --skip-system-test --skip-bootsnap

    cd lamby_rails

    git add .
    git commit -m 'initial'
    ```

- Edit `app/controllers/application_controller.rb`:

    ```diff
    class ApplicationController < ActionController::Base
    +  def index
    +    render html: "<h1>Hello Lamby</h1>".html_safe
    +  end
    end
    ```

  Edit `config/routes.rb`:

    ```diff
    Rails.application.routes.draw do
    +  root to: "application#index"
    end
    ```

- Save progress:

    ```sh
    git add -p
    git commit -m 'hello lamby'
    ```

- Install lamby gems:

    ```sh
    bundle add lamby aws-sdk-ssm
    ```

- Edit `Gemfile`:

    ```diff
    - gem "lamby", "~> 2.0"
    + gem "lamby", "~> 2.0", require: false
    ```

- Finish installing lamby:

    ```sh
    ./bin/rake -r lamby lamby:install

    git add -p
    git status
    git add .
    git commit -m 'install lamby'
    ```

- I set up my AWS credentials here:

    ```
    # ~/.aws/credentials
    [lamby_rails]
    aws_access_key_id = VALUE
    aws_secret_access_key = SECRET_VALUE
    ```

- And the region config here:

    ```
    # ~/.aws/config
    [lamby_rails]
    output = json
    region = us-west-1
    ```

- I set my AWS_PROFILE using [direnv](https://direnv.net). Edit `.envrc`:

    ```
    export AWS_PROFILE=lamby_rails
    ```

  then run:

    ```sh
    direnv allow
    ```

- Configure
    [SSM](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
    w/ Rails master key:

    ```sh
    aws ssm put-parameter \
      --name "/config/lamby_rails/env/RAILS_MASTER_KEY" \
      --type "SecureString" \
      --value $(cat config/master.key)
    ```

- Edit `app.rb` and add this line right after `require 'lamby'`:

    ```ruby
    ENV['RAILS_MASTER_KEY'] =
      Lamby::SsmParameterStore.get!('/config/lamby_rails/env/RAILS_MASTER_KEY')
    ```

- Edit `template.yaml` CloudFormation/SAM file by adding this to the `Properties` section of your `RailsFunction`. This addition allows your Lambda's runtime policy to read configs from SSM Parameter store (see full `template.yml` attached):

    ```
    Policies:
      - Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Action:
              - ssm:GetParameter
              - ssm:GetParameters
              - ssm:GetParametersByPath
              - ssm:GetParameterHistory
            Resource:
              - !Sub arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter/config/lamby_rails/*
    ```

- Save progress:

    ```sh
    git add -p
    git commit -m 'configure lamby'
    ```

- Edit `.envrc` (change the bucket name):

    ```
    export CLOUDFORMATION_BUCKET=lamby-rails-josh
    export AWS_DEFAULT_REGION=us-west-1
    ```

  don't forget:

    ```sh
    direnv allow
    ```

- Now run:

    ```sh
    aws s3 mb "s3://$CLOUDFORMATION_BUCKET"

    ./bin/deploy
    ```

- This uses Docker to bake the Rails app Lambda function. That can take a long time on macOS.
  Go get some coffee or tea. :)

    ```sh
    $ time ./bin/deploy

    Successfully created/updated stack - lambyrails-production-us-west-1 in None
    ./bin/deploy  17.45s user 9.86s system 5% cpu 9:04.13 total
    ```

  (that's the build/deploy time on an 8-core MacBook Pro 🤔)
