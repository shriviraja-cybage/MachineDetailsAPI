#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# Use the official .NET SDK as a build image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["MachineDetailsAPI/MachineDetailsAPI.csproj", "MachineDetailsAPI/"]
RUN dotnet restore "./MachineDetailsAPI/./MachineDetailsAPI.csproj"
COPY . .
WORKDIR "/src/MachineDetailsAPI"
RUN dotnet build "./MachineDetailsAPI.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Use the official .NET runtime as a base image for the published application
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /inetpub/wwwroot
COPY --from=build /app/build .

# Install IIS components
RUN Install-WindowsFeature Web-Server; \
    Remove-Website -Name 'Default Web Site'; \
    New-Website -Name 'MachineDetailsAPI' -Port 80 -PhysicalPath 'C:\inetpub\wwwroot' -ApplicationPool '.NET v6.0' -Force

# Expose the necessary ports
EXPOSE 80

# Start IIS
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
