FROM microsoft/dotnet::sdk

ARG _ACCESS_TOKEN
RUN git clone https://${_ACCESS_TOKEN}:x-oauth-basic@github.com/Atsushi-Hasegawa/TestProject sample

WORKDIR sample

RUN dotnet restore
RUN dotnet publish -c Release -o out

#unittest
RUN dotnet tool install --global coverlet.console

RUN mkdir -p TestProject/TestProjectTest
RUN cd TestProject/TestProjectTest && ¥
  dotnet new xunit
RUN cd TestProject/TestProjectTest && ¥
dotnet test

EXPOSE 3000
ENTRYPOINT ["dotnet", "out/TestProject.dll"]
