import Link from 'next/link';
import { useIssueTracker } from '../../hooks/use-issue-tracker';
import { CICCDBuild } from '../../interfaces/build';
import { BuildStatusIcon } from '../build-status-icon/build-status-icon';
import { Timer } from '../timer';

export function BuildListItem({
  status,
  branchName,
  origin,
  repo,
  name,
  githubRepoOwner,
  commitSha,
  logUrl,
  issueNr = "1",
  commitAuthor,
  commitSubject,
  created,
  startTime,
  finishTime,
  id,
}: CICCDBuild & { id: string }) {


  const { url } = useIssueTracker() || {};

  const options = {
    year: 'numeric', month: 'numeric', day: 'numeric',
    hour: 'numeric', minute: 'numeric', second: 'numeric',
    hour12: false,
  } as const;

  return (
    <tr
      key={id}
      className='border'
    >
      <td
        className='px-8 py-2'
      >
        <BuildStatusIcon
          status={status}
        />
      </td>

      <td
        className='px-8 py-2'
      >
        <Link href={`/repos/${githubRepoOwner}/${repo}/${encodeURIComponent(branchName)}`} >
          <a className='underline'>
            {branchName}
          </a>
        </Link>
      </td>

      <td
        className='px-8 py-2 w-64'
      >
        {commitAuthor}
      </td>

      <td
        className='px-8 py-2'
      >
        {commitSubject}
      </td>

      <td
        className='px-8 py-2 w-40'
      >
        {name}
      </td>


      <td
        className='px-8 py-2'
      >
        {
          (origin === "cloud-build")
            // eslint-disable-next-line
            ? <img alt={origin} src='icons/cloud_build.png' style={{ width: "auto", height: "32px" }} />
            : null
        }
        {
          (origin === "gocd")
            // eslint-disable-next-line
            ? <img alt={origin} src='icons/gocd.png' style={{ width: "auto", height: "16px" }} />
            : null
        }
      </td>

      <td
        className='px-8 py-2  w-40'
      >
        <a
          target="_blank"
          href={`https://github.com/${githubRepoOwner}/${repo}/commit/${commitSha}`} rel="noreferrer">
          {commitSha.substring(0, 7)}
        </a>
      </td>

      <td
        className='px-8 py-2 text-slate-500'
      >
        {new Intl.DateTimeFormat('default', options).format(created)}
      </td>

      <td
        className='px-8 py-2 text-slate-500 w-40'
      >
        <Timer
          finishTime={finishTime}
          startTime={startTime}
        />
      </td>

      <td
        className='px-8 py-2 flex'
      >
        <a
          href={logUrl}
          title='logs'
          target="_blank" rel="noreferrer"
        >
          📄
        </a>

        {
          url && issueNr && <a target="_blank" href={url
            .replace("{0}", issueNr)
            .replace("{1}", githubRepoOwner)
            .replace("{2}", repo)
          } rel="noreferrer">
            🐛
          </a>
        }
      </td>
    </tr>
  );
}
