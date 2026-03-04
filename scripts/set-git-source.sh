#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


if [ -z ${GIT_ORG} ]; then echo "Please set GIT_ORG when running script, optional GIT_BASEURL and GIT_REPO to formed the git url GIT_BASEURL/GIT_ORG/*"; exit 1; fi

set -u

GIT_BRANCH=${GIT_BRANCH:-master}
GIT_BASEURL=${GIT_BASEURL:-https://github.com}
GIT_GITOPS=${GIT_GITOPS:-multi-tenancy-gitops.git}
GIT_GITOPS_BRANCH=${GIT_GITOPS_BRANCH:-${GIT_BRANCH}}
GIT_GITOPS_INFRA=${GIT_GITOPS_INFRA:-multi-tenancy-gitops-infra.git}
GIT_GITOPS_INFRA_BRANCH=${GIT_GITOPS_INFRA_BRANCH:-${GIT_BRANCH}}
GIT_GITOPS_SERVICES=${GIT_GITOPS_SERVICES:-multi-tenancy-gitops-services.git}
GIT_GITOPS_SERVICES_BRANCH=${GIT_GITOPS_SERVICES_BRANCH:-${GIT_BRANCH}}
GIT_GITOPS_APPLICATIONS=${GIT_GITOPS_APPLICATIONS:-multi-tenancy-gitops-apps.git}
GIT_GITOPS_APPLICATIONS_BRANCH=${GIT_GITOPS_APPLICATIONS_BRANCH:-${GIT_BRANCH}}
GIT_GITOPS_NAMESPACE=${GIT_GITOPS_NAMESPACE:-openshift-gitops}
HELM_REPOURL=${HELM_REPOURL:-https://charts.cloudnativetoolkit.dev}



echo "Setting kustomization patches to https://github.com/Demo-HC/multi-tenancy-gitops.git on branch master"
echo "Setting kustomization patches to https://github.com/Demo-HC/multi-tenancy-gitops-infra.git on branch master"
echo "Setting kustomization patches to https://github.com/Demo-HC/multi-tenancy-gitops-services.git on branch master"
echo "Setting kustomization patches to https://github.com/Demo-HC/multi-tenancy-gitops-apps.git on branch master"

find ${SCRIPTDIR}/../0-bootstrap -name '*.yaml' -print0 |
  while IFS= read -r -d '' File; do
    if grep -q "kind: Application\|kind: AppProject" "$File"; then
      #echo "$File"
      sed -i'.bak' -e "s#\${GIT_BASEURL}/\${GIT_ORG}/\${GIT_GITOPS}#https://github.com/Demo-HC/multi-tenancy-gitops.git#" $File
      sed -i'.bak' -e "s#\master#master#" $File
      sed -i'.bak' -e "s#\${GIT_BASEURL}/\${GIT_ORG}/\${GIT_GITOPS_INFRA}#https://github.com/Demo-HC/multi-tenancy-gitops-infra.git#" $File
      sed -i'.bak' -e "s#\master#master#" $File
      sed -i'.bak' -e "s#\${GIT_BASEURL}/\${GIT_ORG}/\${GIT_GITOPS_SERVICES}#https://github.com/Demo-HC/multi-tenancy-gitops-services.git#" $File
      sed -i'.bak' -e "s#\master#master#" $File
      sed -i'.bak' -e "s#\${GIT_BASEURL}/\${GIT_ORG}/\${GIT_GITOPS_APPLICATIONS}#https://github.com/Demo-HC/multi-tenancy-gitops-apps.git#" $File
      sed -i'.bak' -e "s#\master#master#" $File
      sed -i'.bak' -e "s#\openshift-gitops#openshift-gitops#" $File
      sed -i'.bak' -e "s#\${HELM_REPOURL}#${HELM_REPOURL}#" $File
      rm "${File}.bak"
    fi
  done
echo "done replacing variables in kustomization.yaml files"
echo "git commit and push changes now"
