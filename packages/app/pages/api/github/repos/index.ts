import { Octokit } from "@octokit/rest";
import { GetResponseDataTypeFromEndpointMethod } from "@octokit/types";
import { NextApiRequest, NextApiResponse } from "next";

export default async function getRepos(
    req: NextApiRequest,
    res: NextApiResponse<
        GetResponseDataTypeFromEndpointMethod<
            typeof octokit.repos.listForAuthenticatedUser
        >
    >
) {

    const octokit = new Octokit({
        auth: process.env.GITHUB_TOKEN,
    });
    // TODO: allow user to choose to list only private, public, owner, repos
    // and fetch all of them (not only the first page)
    const repos = await octokit.repos.listForAuthenticatedUser({
        type: "all",
        per_page: 100,
    });

    const repoRegex = new RegExp(process.env.NEXT_PUBLIC_REPO_REGEX || '.*');
    const result = repos.data
        .filter((repo) => repoRegex.test(repo.full_name));

    res.status(200).json(result);
}
