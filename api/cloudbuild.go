package cloudbuild

import(
  "cloud.google.com/go/functions/metadata"
  "google.golang.org/api/cloudbuild/v1"
  "github.com/ashwanthkumar/slack-go-webhook"
  "os"
  "fmt"
  "encoding/base64"
  "encoding/json"
  "context"
)

//https://godoc.org/

type PubsubMessage struct {
  Data string `json:"data"`
}

type Slack struct {
  Username string `json:"username"`
  Channel string `json:"channel"`
  Url string `json:"url"`
}

var(
  status = map[string]bool {
    "SUCCESS": true,
    "FAILURE": true,
    "INTERNAL_ERROR": true,
    "TIMEOUT": true,
  }
  projectID string
  resource string
)

func Subscribe(ctx context.Context, message PubsubMessage) error {
  meta, err := metadata.FromContext(ctx)
  if err != nil {
    fmt.Errorf("%v", err)
    return nil
  }
  resource = fmt.Sprintf("projects/%s/topics/cloud-builds", os.Getenv("PUBSUB_PROJECT_ID"))
  if meta.Resource.Name != resource {
    fmt.Errorf("%s is not wathing resource\n", meta.Resource.Name)
    return nil
  }

  build, err := eventToBuild(message.Data)
  if err != nil {
    fmt.Errorf("%v", err)
    return nil
  }
  if _,ok := status[build.Status]; !ok {
    fmt.Printf("%s status is skipped\n", build.Status)
    return nil
  }
  info := Init()
  payload := createSlackMessage(build, info)

  slack.Send(info.Url, "", payload)
  return nil
}

func Init() (*Slack) {
  slack := Slack{}
  slack.Username = os.Getenv("SLACK_USERNAME")
  slack.Channel = os.Getenv("SLACK_CHANNEL")
  slack.Url = os.Getenv("SLACK_WEBHOOK_URL")
  return &slack
}

func eventToBuild(data string) (*cloudbuild.Build, error) {
  decode, err := base64.StdEncoding.DecodeString(data)
  if err != nil {
    fmt.Errorf("%v", err)
  }
  build := cloudbuild.Build{}
  if err = json.Unmarshal(decode, &build); err != nil {
    fmt.Errorf("%v", err)
  }
  return &build, nil
}

func createSlackMessage(build *cloudbuild.Build, info *Slack) slack.Payload {
  title := "Build logs"
  attach := slack.Attachment{
    Title: &title,
    TitleLink: &build.LogUrl,
  }
  attach.AddField(slack.Field{
     Title: "Status",
     Value: build.Status,
 })
  res := slack.Payload {
    Username: info.Username,
    Channel: info.Channel,
    Markdown: true,
    Text: fmt.Sprintf("Build `%s`", build.Id),
    Attachments: []slack.Attachment{attach},
  }
  return res
}
